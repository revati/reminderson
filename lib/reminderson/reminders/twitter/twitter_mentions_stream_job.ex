defmodule Reminderson.Reminders.TwitterMentionsStreamJob do
  use GenServer

  alias Reminderson.Reminders
  alias Reminderson.Reminders.Twitter
  alias Reminderson.Reminders.TweetReminder
  alias ExTwitter.Model.Tweet, as: RawTweet
  require Logger

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def init(config) do
    {:ok, config, {:continue, :subscribe_to_stream}}
  end

  def handle_continue(:subscribe_to_stream, config) do
    # TODO: Extract to seperate process or smth
    spawn(fn ->
      case Twitter.get_last_reminder() do
        nil ->
          nil

        :ok ->
          :ok

        %TweetReminder{} = reminder ->
          stream = ExTwitter.mentions_timeline(count: 200, since_id: reminder.ask_reminder_id)

          for tweet <- stream do
            handle_raw_tweet(tweet, config)
          end
      end
    end)

    stream = ExTwitter.stream_filter(track: "@" <> config[:account_to_fallow])

    for tweet <- stream do
      handle_raw_tweet(tweet, config)
    end

    {:noreply, %{}}
  end

  defp handle_raw_tweet(%RawTweet{} = raw_tweet, config) do
    unless config[:account_to_fallow] === raw_tweet.user.screen_name do
      {:ok, tweet} = Reminders.create_tweet_reminder(raw_tweet)

      # TODO: Extract acknowledgement stuff to worker to be async and wouldnt block stream receiving new tweets
      ack_tweet =
        tweet
        |> Twitter.extract_acknowledgement_text()
        |> ExTwitter.update(
          in_reply_to_status_id: tweet.ask_reminder_id,
          quoted_status_id: tweet.reason_id
        )

      {:ok, _tweet} = Twitter.update_reminder_acknowledgement(tweet, ack_tweet)
    end
  catch
    e ->
      Logger.error(e)
      e
  end

  defp handle_raw_tweet(%ExTwitter.Model.DeletedTweet{} = deleted_tweet, _config) do
    # TODO: mark reminder as deleted and remove reminder worker
    IO.puts("deleted tweet = #{deleted_tweet.status[:id]}")
  end

  defp handle_raw_tweet(%ExTwitter.Model.Limit{} = limit, _config) do
    IO.puts("limit = #{limit.track}")
  end

  defp handle_raw_tweet(%ExTwitter.Model.StallWarning{} = stall_warning, _config) do
    IO.puts("stall warning = #{stall_warning.code}")
  end

  defp handle_raw_tweet(message, _config) do
    IO.inspect(message)
  end

  def handle_info(message, _config) do
    Logger.error("#{__MODULE__} received unexpected message #{message}")
  end
end
