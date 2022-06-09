defmodule Reminder.EventListener do
  use Commanded.Projections.Ecto,
    application: Infrastructure.Commanded,
    repo: Infrastructure.Repo,
    name: __MODULE__

  alias Infrastructure.Oban
  alias Reminder.Jobs.{FetchReasonTextJob, AcknowledgeTweetJob, RemindAboutTweetJob}

  @impl Commanded.Event.Handler
  project %Reminder.TweetRecorded{} = event, _metadata, fn multi ->
    multi
    |> Oban.insert(:reason, FetchReasonTextJob.new(%{id: event.id}))
    |> Oban.insert(:acknowledge, AcknowledgeTweetJob.new(%{id: event.id}))
    |> then(fn multi ->
      if event.remind_at do
        Oban.insert(
          multi,
          :remind,
          RemindAboutTweetJob.new(%{id: event.id}, scheduled_at: event.remind_at)
        )
      else
        multi
      end
    end)
  end
end
