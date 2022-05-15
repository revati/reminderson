defmodule Infrastructure.Dispatcher.ValidationMiddleware do
  alias Infrastructure.Dispatcher.Pipeline

  @validation_context [command?: true]

  def pipe_through(%Pipeline{} = pipeline) do
    pipeline.commands
    |> Enum.reduce({pipeline, true}, fn command, {pipeline, valid?} ->
      changeset =
        pipeline
        |> payload_for_command(command)
        |> command.changeset(@validation_context)

      pipeline = Pipeline.with_data_for_command(pipeline, command, changeset)
      valid? = valid? && changeset.valid?

      {pipeline, valid?}
    end)
    |> then(fn
      {pipeline, true} ->
        pipeline

      {pipeline, false} ->
        pipeline
        |> Map.update!(:data, fn data ->
          data
          |> Enum.map(fn
            {command, %Ecto.Changeset{valid?: true} = changeset} ->
              {command, {:ok, changeset}}

            {command, %Ecto.Changeset{valid?: false} = changeset} ->
              {command, {:error, changeset}}

            {:raw_input, response} ->
              {:raw_input, response}
          end)
        end)
        |> Pipeline.halt_as_error()
    end)
  end

  def handle_response(%Pipeline{} = pipeline), do: unlock_unique(pipeline)
  def handle_error(%Pipeline{} = pipeline), do: unlock_unique(pipeline)

  defp unlock_unique(pipeline) do
    :ok = Infrastructure.Mutex.unlock_all_from_caller()

    pipeline
  end

  defp payload_for_command(pipeline, command) do
    Map.merge(pipeline.data[:raw_input], Keyword.get(pipeline.data, command, %{}))
  end
end
