defmodule Reminderson.Reminders do
  @moduledoc """
  The Reminders context.
  """

  import Ecto.Query, warn: false

  alias Reminderson.Repo
  alias Reminderson.Reminders.Twitter
  alias Reminderson.Reminders.TweetReminder
  alias Reminderson.Reminders.TweetReminderJob
  alias ExTwitter.Model.Tweet, as: RawTweet

  @doc """
  Returns the list of reminders_tweet.

  ## Examples

      iex> list_tweet_reminders()
      [%TweetReminder{}, ...]

  """
  def list_tweet_reminders do
    Repo.all(TweetReminder)
  end

  @doc """
  Gets a single tweet_reminder.

  Raises `Ecto.NoResultsError` if the Tweet reminder does not exist.

  ## Examples

      iex> get_tweet_reminder!(123)
      %TweetReminder{}

      iex> get_tweet_reminder!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tweet_reminder!(id), do: Repo.get!(TweetReminder, id)

  @doc """
  Creates a tweet_reminder.

  ## Examples

      iex> create_tweet_reminder(%{field: value})
      {:ok, %TweetReminder{}}

      iex> create_tweet_reminder(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tweet_reminder(attrs \\ %{})

  def create_tweet_reminder(%RawTweet{} = raw_tweet) do
    payload =
      raw_tweet
      |> Twitter.extract_from_raw_tweet()
      |> Map.put(:reason_text, extract_reason_text(raw_tweet))

    %TweetReminder{}
    |> TweetReminder.changeset(payload)
    |> Repo.insert()
    |> tap(&tap_create_reminder_job/1)
  end

  # def create_tweet_reminder(attrs) do
  #   %TweetReminder{}
  #   |> TweetReminder.changeset(attrs)
  #   |> Repo.insert()
  # end

  @doc """
  Updates a tweet_reminder.

  ## Examples

      iex> update_tweet_reminder(tweet_reminder, %{field: new_value})
      {:ok, %TweetReminder{}}

      iex> update_tweet_reminder(tweet_reminder, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tweet_reminder(%TweetReminder{} = tweet_reminder, attrs) do
    tweet_reminder
    |> TweetReminder.changeset(attrs)
    |> Repo.update()
    |> tap(&tap_create_reminder_job/1)
  end

  @doc """
  Deletes a tweet_reminder.

  ## Examples

      iex> delete_tweet_reminder(tweet_reminder)
      {:ok, %TweetReminder{}}

      iex> delete_tweet_reminder(tweet_reminder)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tweet_reminder(%TweetReminder{} = tweet_reminder) do
    Repo.delete(tweet_reminder)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tweet_reminder changes.

  ## Examples

      iex> change_tweet_reminder(tweet_reminder)
      %Ecto.Changeset{data: %TweetReminder{}}

  """
  def change_tweet_reminder(%TweetReminder{} = tweet_reminder, attrs \\ %{}) do
    TweetReminder.changeset(tweet_reminder, attrs)
  end

  defp tap_create_reminder_job({:ok, %TweetReminder{} = reminder}) do
    cond do
      is_nil(reminder.acknowledgement_id) ->
        %{id: reminder.id}
        |> TweetReminderJob.new()
        |> Oban.insert()

      !is_nil(reminder.remind_at) ->
        %{id: reminder.id}
        |> TweetReminderJob.new(scheduled_at: reminder.remind_at)
        |> Oban.insert()
    end
  end

  defp tap_create_reminder_job({:error, changeset}) do
    {:error, changeset}
  end

  defp extract_reason_text(%RawTweet{in_reply_to_status_id: nil, text: text}) do
    text
  end

  defp extract_reason_text(%RawTweet{in_reply_to_status_id: reply_to}) do
    reply_to
    |> ExTwitter.show()
    |> then(fn
      %{text: text} -> text
      _ -> "Error fetching reason tweet contents"
    end)
  end
end
