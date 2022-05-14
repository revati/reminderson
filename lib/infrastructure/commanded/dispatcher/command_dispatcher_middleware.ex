defmodule Infrastructure.Dispatcher.CommandDispatcherMiddleware do
  alias Infrastructure.Dispatcher.Pipeline

  require Logger

  @command_specific_owerwrites [:timeout]

  def pipe_through(%Pipeline{} = pipeline) do
    pipeline.commands
    |> Enum.reduce_while(pipeline, fn command, pipeline ->
      pipeline.data[command]
      |> execute_command_from_changeset(pipeline.options)
      |> case do
        {:ok, response} ->
          {:cont, Pipeline.with_data_for_command(pipeline, command, {:ok, response})}

        {:error, error} ->
          {:halt,
           pipeline
           |> Pipeline.with_data_for_command(command, {:error, error})
           |> Pipeline.halt_as_error()}
      end
    end)
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
    |> Enum.map(&{&1, Ecto.Changeset.get_field(changeset, &1)})
  end
end
