defmodule Core do
  use Boundary, deps: [Infrastructure]

  defdelegate dispatch(action, params, session, options \\ []), to: Infrastructure.Dispatcher
  defdelegate validate(action, params, session, options \\ []), to: Infrastructure.Dispatcher
end
