defmodule Reminderson.Repo.Migrations.CoreCreateRemindersStateTable do
  use Ecto.Migration

  def change do
    if repo() == Infrastructure.Repo do
      create table(:core_reminders_state, primary_key: false) do
        add :id, :binary_id, primary_key: true
        add :ask_reminder_id, :bigint, null: false
        add :reason_id, :bigint, null: false
        add :acknowledgement_id, :bigint
        add :reminder_id, :bigint
      end
    end
  end
end
