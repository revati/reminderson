defmodule Reminderson.Repo.Migrations.CoreCreateRemindersStateTable do
  use Ecto.Migration

  def change do
    if repo() == Infrastructure.Repo do
      create table(:core_reminders_state, primary_key: false) do
        add :id, :binary_id, primary_key: true
        add :reason_id, :bigint, null: false
        add :ask_reminder_id, :bigint, null: false
        add :acknowledgement_id, :bigint
        add :reminder_id, :bigint
      end

      create unique_index(:core_reminders_state, [:ask_reminder_id])
      create unique_index(:core_reminders_state, [:acknowledgement_id])
      create unique_index(:core_reminders_state, [:reminder_id])
    end
  end
end
