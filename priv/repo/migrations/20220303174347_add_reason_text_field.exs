defmodule Reminderson.Repo.Migrations.AddReasonTextField do
  use Ecto.Migration

  def change do
    if repo() == Reminderson.Repo do
      alter table(:reminders_tweet, primary_key: false) do
        add :reason_text, :string
      end
    end
  end
end
