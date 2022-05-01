defmodule Infrastructure.Router do
  use Boundary, top_level?: true, deps: [Reminder, CRUD]

  @moduledoc false

  use Commanded.Commands.Router

  dispatch [
             Reminder.RecordTweet,
             Reminder.FetchTweetReasonText,
             Reminder.AcknowledgeTweet,
             Reminder.RemindAboutTweet
           ],
           to: Reminder.Aggregate,
           identity: :id

  identify CRUD.Aggregate, by: :id, prefix: "crud-"
  dispatch [CRUD.UpdateEntity, CRUD.RemoveEntity], to: CRUD.Aggregate
end
