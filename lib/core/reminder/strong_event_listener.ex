defmodule Reminder.StrongEventListener do
  use Commanded.Projections.Ecto,
    application: Infrastructure.Commanded,
    repo: Infrastructure.Repo,
    name: __MODULE__,
    consistency: :strong

  project %Reminder.TweetRecorded{} = event, _metadata, fn multi ->
    Ecto.Multi.insert(multi, :recorded, Reminder.Reminder.recorded_changeset(event))
  end

  project %Reminder.TweetAcknowledged{} = event, _metadata, fn multi ->
    reminder = Infrastructure.Repo.get!(Reminder.Reminder, event.id)

    Ecto.Multi.insert(
      multi,
      :acknowledgement,
      Reminder.Reminder.acknowledgement_changeset(reminder, event)
    )
  end

  project %Reminder.RemindedAboutTweet{} = event, _metadata, fn multi ->
    reminder = Infrastructure.Repo.get!(Reminder.Reminder, event.id)

    Ecto.Multi.insert(
      multi,
      :reminded,
      Reminder.Reminder.reminded_changeset(reminder, event)
    )
  end
end
