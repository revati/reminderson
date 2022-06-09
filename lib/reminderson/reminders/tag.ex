defmodule Reminderson.Reminders.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tweet_tags" do
    field :tag, :string

    many_to_many :reminders, Reminderson.Reminders.Reminder,
      join_through: "tweet_reminders_tags",
      unique: true
  end

  def changeset(tag \\ %__MODULE__{}, attrs)

  def changeset(tag, attrs) when is_struct(attrs) do
    changeset(tag, Map.from_struct(attrs))
  end

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:tag])
    |> validate_required([:tag])
  end
end
