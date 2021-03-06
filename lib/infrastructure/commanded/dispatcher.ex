defmodule Infrastructure.Dispatcher do
  alias Infrastructure.Dispatcher.{
    AuthenticationMiddleware,
    AutogenerateValuesMiddleware,
    CommandDispatcherMiddleware,
    ValidationMiddleware,
    Pipeline
  }

  @dispatch_middlewares [
    AuthenticationMiddleware,
    AutogenerateValuesMiddleware,
    ValidationMiddleware,
    CommandDispatcherMiddleware
  ]

  @validation_middlewares [
    AuthenticationMiddleware,
    AutogenerateValuesMiddleware,
    ValidationMiddleware
  ]

  def dispatch(command, params, session, options \\ []) do
    command
    |> Pipeline.initiate(params, options, session)
    |> Pipeline.execute(@dispatch_middlewares)
    |> Pipeline.to_response()
  end

  def validate(command, params, session, options \\ []) do
    command
    |> Pipeline.initiate(params, options, session)
    |> Pipeline.execute(@validation_middlewares)
    |> Pipeline.to_response()
  end
end
