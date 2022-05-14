defmodule Infrastructure.Dispatcher.PipelineExecutor do
  alias Infrastructure.Dispatcher.Pipeline

  def execute(%Pipeline{} = pipeline, middlewares) when is_list(middlewares) do
    do_execute(pipeline, {middlewares, []})
  end

  defp do_execute(%Pipeline{stage: :pipe_through} = pipeline, {[], done}) do
    pipeline
    |> Pipeline.halt_as_success()
    |> do_execute({[], done})
  end

  defp do_execute(%Pipeline{stage: :pipe_through} = pipeline, {[current | todo], done}) do
    current
    |> apply(:pipe_through, [pipeline])
    |> do_execute({todo, [current | done]})
  end

  defp do_execute(%Pipeline{stage: :response} = pipeline, {not_reached, [current | done]}) do
    current
    |> apply(:handle_response, [pipeline])
    |> do_execute({[current | not_reached], done})
  end

  defp do_execute(%Pipeline{stage: :response} = pipeline, {_not_reached, []}) do
    pipeline
  end

  defp do_execute(%Pipeline{stage: :error} = pipeline, {not_reached, [current | done]}) do
    current
    |> apply(:handle_error, [pipeline])
    |> do_execute({[current | not_reached], done})
  end

  defp do_execute(%Pipeline{stage: :error} = pipeline, {_not_reached, []}) do
    pipeline
  end
end
