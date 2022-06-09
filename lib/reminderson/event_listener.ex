defmodule Reminderson.EventListener do
  use Commanded.Projections.Ecto,
    application: Infrastructure.Commanded,
    repo: Reminderson.Repo,
    name: __MODULE__

  alias Reminderson.Reminders.Reminder, as: ReminderStruct
  alias Reminderson.Reminders.Tag, as: TagStruct

  @impl Commanded.Event.Handler
  project event, _metadata, fn multi ->
    case event do
      %Reminder.TweetRecorded{} = event ->
        raw_tags = Map.get(event, :tags)

        multi
        |> Ecto.Multi.insert_all(
          :inset_tags,
          TagStruct,
          Enum.map(raw_tags, &%{tag: &1}),
          on_conflict: :nothing,
          conflict_target: :tag
        )
        |> Ecto.Multi.run(:tags, fn repo, _ ->
          {:ok, repo.all(from t in TagStruct, where: t.tag in ^raw_tags)}
        end)
        |> Ecto.Multi.insert(:reminder, fn %{tags: tags} ->
          event
          |> Map.put(:tags, tags)
          |> ReminderStruct.changeset()
        end)

      %reminder_update_event{} = event
      when reminder_update_event in [
             Reminder.ReasonTextFetched,
             Reminder.TweetAcknowledged,
             Reminder.RemindedAboutTweet
           ] ->
        ReminderStruct
        |> Reminderson.Repo.get(event.id)
        |> Reminderson.Repo.preload([:tags])
        |> case do
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
