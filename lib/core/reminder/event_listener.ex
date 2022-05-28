defmodule Reminder.EventListener do
  use Commanded.Projections.Ecto,
    application: Infrastructure.Commanded,
    repo: Infrastructure.Repo,
    name: __MODULE__

  alias Infrastructure.Oban
  alias Reminder.Jobs.{FetchReasonTextJob, AcknowledgeTweetJob, RemindAboutTweetJob}

  @impl Commanded.Event.Handler
  project %Reminder.TweetRecorded{} = event, _metadata, fn multi ->
    remind_job_opts = if event.remind_at, do: [scheduled_at: event.remind_at], else: []

    multi
    # |> Oban.insert(:reason, FetchReasonTextJob.new(%{id: event.id}))
    # |> Oban.insert(:acknowledge, AcknowledgeTweetJob.new(%{id: event.id}))
    # |> Oban.insert(:remind, RemindAboutTweetJob.new(%{id: event.id}, remind_job_opts))
  end
end
