defmodule Reminder.Repo do
  import Ecto.Query

  def recorded_changeset(changes) do
    Reminder.State.recorded_changeset(changes)
  end

  def acknowledgement_changeset(id, changes) do
    Reminder.State
    |> Infrastructure.Repo.get!(id)
    |> Reminder.State.acknowledgement_changeset(changes)
  end

  def reminded_changeset(id, changes) do
    Reminder.State
    |> Infrastructure.Repo.get!(id)
    |> Reminder.State.reminded_changeset(changes)
  end

  def get_latest_ask_id() do
    Infrastructure.Repo.one!(from s in Reminder.State, select: max(s.ask_reminder_id))
  end
end
