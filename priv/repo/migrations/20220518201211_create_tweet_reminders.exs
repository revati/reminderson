defmodule Reminderson.Repo.Migrations.CreateTweetReminders do
  use Ecto.Migration

  def change do
    if repo() == Reminderson.Repo do
      create table(:tweet_reminders, primary_key: false) do
        add :id, :binary_id, primary_key: true
        add :ask_reminder_id, :bigint, null: false
        add :reason_id, :bigint, null: false
        add :acknowledgement_id, :bigint
        add :reminder_id, :bigint
        add :ask_reminder_screen_name, :string
        add :reason_screen_name, :string
        add :text, :string
        add :parsed_text, :string
        add :reason_text, :string
        add :tags, {:array, :string}
        add :remind_at, :utc_datetime

        timestamps()
      end

      create unique_index(:tweet_reminders, [:reminder_id])
      create unique_index(:tweet_reminders, [:acknowledgement_id])
      create unique_index(:tweet_reminders, [:ask_reminder_id])
    end
  end
end
