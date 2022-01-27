defmodule Reminderson.Repo.Migrations.CreateRemindersTweet do
  use Ecto.Migration

  def change do
    create table(:reminders_tweet, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :reason_id, :bigint
      add :ask_reminder_id, :bigint
      add :acknowledgement_id, :bigint
      add :reminder_id, :bigint
      add :reason_screen_name, :string
      add :ask_reminder_screen_name, :string
      add :text, :string
      add :tags, {:array, :string}, default: []
      add :remind_at, :naive_datetime

      timestamps()
    end

    create unique_index(:reminders_tweet, [:reminder_id])
    create unique_index(:reminders_tweet, [:acknowledgement_id])
    create unique_index(:reminders_tweet, [:ask_reminder_id])
  end
end
