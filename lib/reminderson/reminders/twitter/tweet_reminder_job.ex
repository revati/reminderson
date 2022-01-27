defmodule Reminderson.Reminders.TweetReminderJob do
  use Oban.Worker, queue: :reminders

  alias Reminderson.Reminders
  alias Reminderson.Reminders.Twitter

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id} = _args}) do
    tweet = Reminders.get_tweet_reminder!(id)

    # TODO: Check if tweet deleted
    if tweet.reminder_id do
      :ok
    else
      text = Twitter.extract_reminder_text(tweet)

      reminder_tweet =
        ExTwitter.update(text,
          in_reply_to_status_id: tweet.acknowledgement_id,
          quoted_status_id: tweet.reason_id
        )

      {:ok, _tweet} = Twitter.update_reminder_reminder(tweet, reminder_tweet)
    end

    :ok
  end
end
