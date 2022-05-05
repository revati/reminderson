defmodule Infrastructure do
  use Boundary,
    deps: [
      Infrastructure.Router,
      Infrastructure.Repo,
      Infrastructure.Oban,
      CRUD,
      Reminder,
      ChangesetHelpers,
      EnumHelpers
    ],
    exports: [Dispatcher]

  defdelegate dispatch(action, params, session, options \\ []), to: Infrastructure.Dispatcher
  defdelegate validate(action, params, session, options \\ []), to: Infrastructure.Dispatcher
end
