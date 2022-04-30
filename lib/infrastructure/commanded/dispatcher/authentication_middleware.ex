defmodule Infrastructure.Dispatcher.AuthenticationMiddleware do
  alias Infrastructure.Dispatcher.Pipeline

  def pipe_through(%Pipeline{} = pipeline), do: pipeline
  def handle_response(%Pipeline{} = pipeline), do: pipeline
  def handle_error(%Pipeline{} = pipeline), do: pipeline
end
