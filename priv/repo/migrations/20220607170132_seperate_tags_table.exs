defmodule Reminderson.Repo.Migrations.SeperateTagsTable do
  use Ecto.Migration

  def change do
    if repo() == Reminderson.Repo do
      execute "TRUNCATE tweet_reminders"

      execute "DELETE FROM projection_versions WHERE projection_name = 'Reminderson.EventListener'"

      alter table(:tweet_reminders) do
        remove(:tags)
      end

      create table(:tweet_tags, primary_key: false) do
        add :id, :binary_id, primary_key: true
        add :tag, :string
      end

      create unique_index(:tweet_tags, [:tag])

      create table(:tweet_reminders_tags, primary_key: false) do
        add :reminder_id, references(:tweet_reminders, type: :binary_id)
        add :tag_id, references(:tweet_tags, type: :binary_id)
      end

      create unique_index(:tweet_reminders_tags, [:reminder_id, :tag_id])
    end

    if repo() == Infrastructure.Repo do
      execute "UPDATE subscriptions SET last_seen = 0 WHERE subscription_name = 'Reminderson.EventListener'"
    end
  end
end
