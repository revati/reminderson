defmodule Reminder.EventListener do
  use Commanded.Event.Handler,
    application: Infrastructure.Commanded,
    name: __MODULE__

  @impl Commanded.Event.Handler
  def handle(%Reminder.TweetRecorded{} = event, _metadata) do
    {:ok, _job} =
      %{id: event.id}
      |> Reminder.ReasonTextFetcherJob.new()
      |> Oban.insert()

    :ok
  end
end
