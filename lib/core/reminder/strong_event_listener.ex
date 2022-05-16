defmodule Reminder.StrongEventListener do
  use Commanded.Projections.Ecto,
    application: Infrastructure.Commanded,
    repo: Infrastructure.Repo,
    name: __MODULE__,
    consistency: :strong

  project %Reminder.TweetRecorded{} = event, fn multi ->
    Ecto.Multi.insert(multi, :recorded, Reminder.State.recorded_changeset(event))
  end

  project %Reminder.TweetAcknowledged{} = event, fn multi ->
    Ecto.Multi.update(
      multi,
      :acknowledgement,
      Reminder.State
      |> Infrastructure.Repo.get!(event.id)
      |> Reminder.State.acknowledgement_changeset(event)
    )
  end

  project %Reminder.RemindedAboutTweet{} = event, fn multi ->
    Ecto.Multi.update(
      multi,
      :reminded,
      Reminder.State
      |> Infrastructure.Repo.get!(event.id)
      |> Reminder.State.reminded_changeset(event)
    )
  end
end
