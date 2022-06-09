defmodule Reminderson.Reminders do
  @moduledoc """
  The Reminders context.
  """

  import Ecto.Query, warn: false

  alias Reminderson.Repo
  alias Reminderson.Reminders.Reminder
  alias Reminderson.Reminders.Tag

  @doc """
  Returns the list of tweet_reminders.

  ## Examples

      iex> list_tweet_reminders()
      [%Reminder{}, ...]

  """
  def list_tweet_reminders(params) do
    Reminder
    |> order_by([q], desc: q.created_at)
    |> apply_filters(params)
    |> Repo.all()
    |> Repo.preload(:tags)
  end

  def ask_reminder_screen_name_list(_params) do
    Reminder
    |> select([:ask_reminder_screen_name])
    |> distinct(true)
    |> Repo.all()
    |> Enum.map(& &1.ask_reminder_screen_name)
  end

  def reason_screen_name_list(_params) do
    Reminder
    |> select([:reason_screen_name])
    |> distinct(true)
    |> Repo.all()
    |> Enum.map(& &1.reason_screen_name)
  end

  def tags_list(params) do
    Tag
    |> then(fn query ->
      cond do
        is_list(params[:tag]) -> where(query, [q], q.tag in ^params[:tag])
        is_binary(params[:tag]) -> where(query, tag: ^params[:tag])
        true -> query
      end
    end)
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
  def get_reminder!(id), do: Reminder |> Repo.get!(id) |> Repo.preload(:tags)

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

  defp apply_filters({_key, value}, query) when value in [nil, ""], do: query

  defp apply_filters({key, value}, query)
       when key in [:ask_reminder_screen_name, "ask_reminder_screen_name"],
       do: where(query, ask_reminder_screen_name: ^value)

  defp apply_filters({key, value}, query)
       when key in [:reason_screen_name, "reason_screen_name"],
       do: where(query, reason_screen_name: ^value)

  defp apply_filters({key, value}, query)
       when key in [:tags, "tags"] do
    query
    |> join(:left, [q], assoc(q, :tags), as: :tags)
    |> where([tags: t], t.tag in ^value)
    |> distinct([q], q.id)
  end

  defp apply_filters(query, params) do
    Enum.reduce(params, query, &apply_filters/2)
  end
end
