defmodule Reminderson.EventListener do
  use Commanded.Projections.Ecto,
    application: Infrastructure.Commanded,
    repo: Reminderson.Repo,
    name: __MODULE__

  alias Reminderson.Reminders.Reminder, as: ReminderStruct

  @impl Commanded.Event.Handler
  project event, _metadata, fn multi ->
    case event do
      %Reminder.TweetRecorded{} = event ->
        Ecto.Multi.insert(
          multi,
          :reminder,
          ReminderStruct.changeset(event)
        )

      %reminder_update_event{} = event
      when reminder_update_event in [
             Reminder.ReasonTextFetched,
             Reminder.TweetAcknowledged,
             Reminder.RemindedAboutTweet
           ] ->
        case Reminderson.Repo.get(ReminderStruct, event.id) do
          nil ->
            multi

          reminder ->
            Ecto.Multi.update(
              multi,
              :reminder,
              ReminderStruct.changeset(reminder, event)
            )
        end
    end
  end
end
