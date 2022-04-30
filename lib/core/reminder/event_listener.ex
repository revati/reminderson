defmodule Reminder.EventListener do
  use Commanded.Event.Handler,
    application: Infrastructure.Commanded,
    name: __MODULE__

  @impl Commanded.Event.Handler
  def handle(%Reminder.Recorded{ask_reminder_id: id, reason_id: id} = event, _metadata) do
    payload = %{id: event.id, reason_text: event.text}
    meta = %{system: true}
    Reminderson.dispatch(Reminder.StoreReasonText, payload, meta)
  end

  @impl Commanded.Event.Handler
  def handle(%Reminder.Recorded{reason_id: reason_id} = event, _metadata) do
    {:ok, _job} =
      %{id: event.id, reason_id: reason_id}
      |> Reminder.ReasonTextFetcherJob.new()
      |> Oban.insert()

    :ok
  end
end
