defmodule Reminderson.Reminders.Reminder do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tweet_reminders" do
    field :acknowledgement_id, :integer
    field :ask_reminder_id, :integer
    field :ask_reminder_screen_name, :string
    field :parsed_text, :string
    field :reason_id, :integer
    field :reason_screen_name, :string
    field :reason_text, :string
    field :remind_at, :utc_datetime
    field :reminder_id, :integer
    field :tags, {:array, :string}
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(reminder \\ %__MODULE__{}, attrs)

  def changeset(reminder, attrs) when is_struct(attrs) do
    changeset(reminder, Map.from_struct(attrs))
  end

  def changeset(reminder, attrs) do
    reminder
    |> cast(attrs, [
      :ask_reminder_id,
      :reason_id,
      :acknowledgement_id,
      :reminder_id,
      :ask_reminder_screen_name,
      :reason_screen_name,
      :text,
      :parsed_text,
      :reason_text,
      :tags,
      :remind_at
    ])
    |> validate_required([
      :ask_reminder_id,
      :reason_id,
      :ask_reminder_screen_name,
      :reason_screen_name,
      :remind_at
    ])
    |> unique_constraint(:reminder_id)
    |> unique_constraint(:acknowledgement_id)
    |> unique_constraint(:ask_reminder_id)
  end
end
