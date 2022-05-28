defmodule Reminderson.Reminders do
  @moduledoc """
  The Reminders context.
  """

  import Ecto.Query, warn: false

  alias Reminderson.Repo
  alias Reminderson.Reminders.Reminder

  @doc """
  Returns the list of tweet_reminders.

  ## Examples

      iex> list_tweet_reminders()
      [%Reminder{}, ...]

  """
  def list_tweet_reminders do
    Reminder
    |> order_by([q], desc: q.created_at)
    |> Repo.all()
  end

  @doc """
  Gets a single reminder.

  Raises `Ecto.NoResultsError` if the Reminder does not exist.

  ## Examples

      iex> get_reminder!(123)
      %Reminder{}

      iex> get_reminder!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reminder!(id), do: Repo.get!(Reminder, id)

  @doc """
  Creates a reminder.

  ## Examples

      iex> create_reminder(%{field: value})
      {:ok, %Reminder{}}

      iex> create_reminder(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reminder(attrs \\ %{}) do
    %Reminder{}
    |> Reminder.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a reminder.

  ## Examples

      iex> update_reminder(reminder, %{field: new_value})
      {:ok, %Reminder{}}

      iex> update_reminder(reminder, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reminder(%Reminder{} = reminder, attrs) do
    reminder
    |> Reminder.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a reminder.

  ## Examples

      iex> delete_reminder(reminder)
      {:ok, %Reminder{}}

      iex> delete_reminder(reminder)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reminder(%Reminder{} = reminder) do
    Repo.delete(reminder)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reminder changes.

  ## Examples

      iex> change_reminder(reminder)
      %Ecto.Changeset{data: %Reminder{}}

  """
  def change_reminder(%Reminder{} = reminder, attrs \\ %{}) do
    Reminder.changeset(reminder, attrs)
  end
end
