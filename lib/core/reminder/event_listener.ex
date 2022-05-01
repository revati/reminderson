defmodule Reminder.EventListener do
  use Commanded.Event.Handler,
    application: Infrastructure.Commanded,
    name: __MODULE__

  @impl Commanded.Event.Handler
  def handle(%Reminder.TweetRecorded{} = event, _metadata) do
    {:ok, _job} = Reminder.Jobs.FetchReasonTextJob.initiate(event.id)
    {:ok, _job} = Reminder.Jobs.AcknowledgeTweetJob.initiate(event.id)
    {:ok, _job} = Reminder.Jobs.RemindAboutTweetJob.initiate(event.id, event.remind_at)

    :ok
  end
end
