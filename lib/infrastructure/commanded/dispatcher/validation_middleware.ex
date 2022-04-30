defmodule Infrastructure.Dispatcher.ValidationMiddleware do
  alias Infrastructure.Dispatcher.Pipeline

  def pipe_through(%Pipeline{} = pipeline) do
    pipeline
    |> validate_commands()
    |> case do
      %{valid?: true, changesets: changesets} ->
        Pipeline.with_input(pipeline, changesets)

      %{valid?: false, changesets: changesets} ->
        Pipeline.with_error(pipeline, changesets)
    end
  end

  def handle_response(%Pipeline{} = pipeline), do: pipeline
  def handle_error(%Pipeline{} = pipeline), do: pipeline

  defp validate_commands(pipeline) do
    pipeline.commands
    |> Enum.reduce(%{changesets: [], valid?: true}, fn
      command, %{changesets: changesets, valid?: valid?} ->
        command_input = Pipeline.input_for_command(pipeline, command)
        changeset = apply(command, :changeset, [command_input])

        %{changesets: [{command, changeset} | changesets], valid?: valid? && changeset.valid?}
    end)
    |> then(fn %{valid?: valid?, changesets: changesets} ->
      %{valid?: valid?, changesets: Enum.reverse(changesets)}
    end)
  end
end
