defmodule Reminder.EventListener do
  use Commanded.Event.Handler,
    application: Infrastructure.Commanded,
    name: __MODULE__

  alias Infrastructure.{Oban, Repo}
  alias Reminder.Jobs.{FetchReasonTextJob, AcknowledgeTweetJob, RemindAboutTweetJob}
  @impl Commanded.Event.Handler
  def handle(%Reminder.TweetRecorded{} = event, _metadata) do
    remind_at = event.remind_at

    Ecto.Multi.new()
    |> Oban.insert(:reason, FetchReasonTextJob.new(%{id: event.id}))
    |> Oban.insert(:acknowledge, AcknowledgeTweetJob.new(%{id: event.id}))
    |> Oban.insert(:remind, RemindAboutTweetJob.new(%{id: event.id}, scheduled_at: remind_at))
    |> Repo.transaction()
  end
end
