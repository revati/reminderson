defmodule Reminder.StrongEventListener do
  use Commanded.Projections.Ecto,
    application: Infrastructure.Commanded,
    repo: Infrastructure.Repo,
    name: __MODULE__,
    consistency: :strong

  project %Reminder.TweetRecorded{} = event, fn multi ->
    Ecto.Multi.insert(multi, :recorded, Reminder.Repo.recorded_changeset(event))
  end

  project %Reminder.TweetAcknowledged{} = event, fn multi ->
    Ecto.Multi.update(
      multi,
      :acknowledgement,
      Reminder.Repo.acknowledgement_changeset(event.id, event)
    )
  end

  project %Reminder.RemindedAboutTweet{} = event, fn multi ->
    Ecto.Multi.update(
      multi,
      :reminded,
      Reminder.Repo.reminded_changeset(event.id, event)
    )
  end
end
