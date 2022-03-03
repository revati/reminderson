defmodule Reminderson.Reminders.TweetReminderJob do
  use Oban.Worker, queue: :twitter_bot

  alias Reminderson.Reminders
  alias Reminderson.Reminders.Twitter

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id} = _args}) do
    tweet = Reminders.get_tweet_reminder!(id)

    cond do
      is_nil(tweet.acknowledgement_id) ->
        # TODO: Extract acknowledgement stuff to worker to be async and wouldnt block stream receiving new tweets
        ack_tweet =
          tweet
          |> Twitter.extract_acknowledgement_text()
          |> ExTwitter.update(
            in_reply_to_status_id: tweet.ask_reminder_id,
            quoted_status_id: tweet.reason_id
          )

        {:ok, _tweet} = Twitter.update_reminder_acknowledgement(tweet, ack_tweet)

      is_nil(tweet.reminder_id) ->
        text = tweet

        reminder_tweet =
          tweet
          |> Twitter.extract_reminder_text()
          |> ExTwitter.update(
            in_reply_to_status_id: tweet.acknowledgement_id,
            quoted_status_id: tweet.reason_id
          )

        {:ok, _tweet} = Twitter.update_reminder_reminder(tweet, reminder_tweet)

      true ->
        :ok
    end

    :ok
  end
end
