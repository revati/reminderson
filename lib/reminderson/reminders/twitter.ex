defmodule Reminderson.Reminders.Twitter do
  alias Reminderson.Repo
  alias Reminderson.Reminders.TweetReminder
  alias Reminderson.Reminders.TweetReminderJob
  alias Reminderson.Reminders.TweetTextParser
  alias ExTwitter.Model.Tweet, as: RawTweet

  import Ecto.Query

  def get_last_reminder() do
    TweetReminder
    |> order_by(desc: :inserted_at)
    |> limit(1)
    |> Repo.one()
  end

  def update_reminder_acknowledgement(%TweetReminder{} = reminder, %RawTweet{} = raw) do
    reminder
    |> update_tweet_reminder(%{acknowledgement_id: raw.id})
    |> tap(&tap_create_reminder_job/1)
  end

  def update_reminder_reminder(%TweetReminder{} = reminder, %RawTweet{} = raw) do
    update_tweet_reminder(reminder, %{reminder_id: raw.id})
  end

  defp update_tweet_reminder(%TweetReminder{} = tweet_reminder, attrs) do
    tweet_reminder
    |> TweetReminder.changeset(attrs)
    |> Repo.update()
  end

  def extract_from_raw_tweet(%RawTweet{} = reminder) do
    {:ok, datetime, text, tags} = TweetTextParser.parse(reminder.text)

    datetime =
      if is_nil(datetime),
        do: nil,
        else: datetime |> Timex.Timezone.convert("Etc/UTC") |> DateTime.to_naive()

    %{
      type: :tweet,
      text: text,
      tags: tags,
      remind_at: datetime,
      ask_reminder_id: reminder.id,
      ask_reminder_screen_name: reminder.user.screen_name,
      reason_id: reminder.in_reply_to_status_id || reminder.id,
      reason_screen_name:
        if(reminder.in_reply_to_status_id,
          do: reminder.in_reply_to_screen_name,
          else: reminder.user.screen_name
        )
    }
  end

  def extract_acknowledgement_text(%TweetReminder{remind_at: nil} = reminder) do
    tweet_link = quote_tweet_link(reminder)

    "@#{reminder.ask_reminder_screen_name} pieglabāšu šo tweetu vēlākam #{tweet_link}"
  end

  def extract_acknowledgement_text(%TweetReminder{} = reminder) do
    tweet_link = quote_tweet_link(reminder)

    "@#{reminder.ask_reminder_screen_name} atgadinasu tev par šo tweetu #{NaiveDateTime.to_string(reminder.remind_at)} #{tweet_link}"
  end

  def extract_reminder_text(%TweetReminder{} = reminder) do
    tags = reminder.tags |> Enum.map(&"##{&1}") |> Enum.join(" ")
    tweet_link = quote_tweet_link(reminder)

    "@#{reminder.ask_reminder_screen_name} Atgādinu: #{reminder.text} #{tags} #{tweet_link}"
  end

  defp quote_tweet_link(%TweetReminder{} = reminder) do
    "https://twitter.com/#{reminder.reason_screen_name}/status/#{Integer.to_string(reminder.reason_id)}"
  end

  defp tap_create_reminder_job({:ok, %TweetReminder{} = reminder}) do
    if reminder.remind_at do
      %{id: reminder.id}
      |> TweetReminderJob.new(scheduled_at: reminder.remind_at)
      |> Oban.insert()
    end

    {:ok, reminder}
  end

  defp tap_create_reminder_job({:error, changeset}) do
    {:error, changeset}
  end
end
