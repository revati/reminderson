defmodule Infrastructure.Router do
  @moduledoc false

  use Commanded.Commands.Router

  dispatch [Reminder.Record, Reminder.StoreReasonText], to: Reminder, identity: :id

  identify CRUD.Aggregate, by: :id, prefix: "crud-"
  dispatch CRUD.UpdateEntity, to: CRUD.Aggregate
  dispatch CRUD.RemoveEntity, to: CRUD.Aggregate
end
