defmodule Reminderson.Reminders.TweetReminder do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "reminders_tweet" do
    field :acknowledgement_id, :integer
    field :ask_reminder_id, :integer
    field :ask_reminder_screen_name, :string
    field :reason_id, :integer
    field :reason_screen_name, :string
    field :remind_at, :naive_datetime
    field :reminder_id, :integer
    field :tags, {:array, :string}
    field :text, :string
    field :reason_text, :string

    timestamps()
  end

  @doc false
  def changeset(tweet_reminder, attrs) do
    tweet_reminder
    |> cast(attrs, [
      :reason_id,
      :ask_reminder_id,
      :acknowledgement_id,
      :reminder_id,
      :reason_screen_name,
      :ask_reminder_screen_name,
      :text,
      :reason_text,
      :tags,
      :remind_at
    ])
    |> validate_required([
      :reason_id,
      :reason_screen_name,
      :ask_reminder_id,
      :ask_reminder_screen_name,
      :reason_text
    ])
    |> unique_constraint(:ask_reminder_id)
    |> unique_constraint(:acknowledgement_id)
    |> unique_constraint(:reminder_id)
  end
end
