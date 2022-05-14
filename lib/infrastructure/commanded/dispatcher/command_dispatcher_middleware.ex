defmodule Infrastructure.Dispatcher.CommandDispatcherMiddleware do
  alias Infrastructure.Dispatcher.Pipeline

  @command_specific_owerwrites [:timeout]

  def pipe_through(%Pipeline{} = pipeline) do
    case execute_command_from_changeset(pipeline.input, pipeline.assigns.options) do
      {:error, reason} -> Pipeline.with_error(pipeline, reason)
      response -> Pipeline.respond(pipeline, response)
    end
  end

  def handle_response(%Pipeline{} = pipeline), do: pipeline
  def handle_error(%Pipeline{} = pipeline), do: pipeline

  defp execute_command_from_changeset(%Ecto.Changeset{} = changeset, options) do
    options = options_with_command_owerwrites(options, changeset.data.__struct__)

    changeset
    |> Ecto.Changeset.apply_changes()
    |> Infrastructure.Commanded.dispatch(options)
    |> case do
      :ok -> {:ok, extract_primary_keys_with_values(changeset)}
      {:error, error} -> {:error, error}
    end
  end

  defp execute_command_from_changeset(changesets, options) do
    changesets
    |> Enum.reduce_while([], fn {command, changeset}, acc ->
      changeset
      |> execute_command_from_changeset(options)
      |> case do
        {:ok, response} -> {:cont, Keyword.put(acc, command, response)}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp options_with_command_owerwrites(options, command) do
    @command_specific_owerwrites
    |> Enum.reduce(options, fn key, options ->
      if Keyword.has_key?(command.__info__(:functions), key),
        do: Keyword.put(options, key, apply(command, key, [])),
        else: options
    end)
  end

  defp extract_primary_keys_with_values(changeset) do
    :primary_key
    |> changeset.data.__struct__.__schema__()
    |> Enum.into(%{}, &{&1, Ecto.Changeset.get_field(changeset, &1)})
  end
end
