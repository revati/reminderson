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
    Ecto.Multi.update(
      multi,
      :acknowledgement,
      Reminder.Reminder
      |> Infrastructure.Repo.get!(event.id)
      |> Reminder.Reminder.acknowledgement_changeset(event)
    )
  end

  project %Reminder.RemindedAboutTweet{} = event, _metadata, fn multi ->
    Ecto.Multi.update(
      multi,
      :reminded,
      Reminder.Reminder
      |> Infrastructure.Repo.get!(event.id)
      |> Reminder.Reminder.reminded_changeset(event)
    )
  end
end
