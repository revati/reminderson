defmodule Reminderson do
  use Boundary,
    deps: [Infrastructure, Infrastructure.EventStore, Reminder],
    exports: [Reminders, Reminders.Reminder]

  @moduledoc """
  Reminderson keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
end
