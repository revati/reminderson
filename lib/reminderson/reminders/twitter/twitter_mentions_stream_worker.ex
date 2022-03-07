defmodule Reminderson.Reminders.TwitterMentionsStreamWorker do
  use GenServer

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

        %TweetReminder{} = reminder ->
          timeline =
            [count: 200, since_id: reminder.ask_reminder_id]
            |> ExTwitter.mentions_timeline()

          for tweet <- timeline do
            handle_raw_tweet(tweet, config)
          end
      end
    end)

    stream =
      [track: "@" <> config[:account_to_fallow]]
      |> ExTwitter.stream_filter(:infinity)

    for tweet <- stream do
      handle_raw_tweet(tweet, config)
    end

    {:noreply, %{}}
  end

  defp handle_raw_tweet(%RawTweet{} = raw_tweet, config) do
    unless config[:account_to_fallow] === raw_tweet.user.screen_name do
      {:ok, _tweet} = Twitter.create_reminder(raw_tweet)
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
    IO.inspect(message, label: :handle_raw_tweet)
  end

  def handle_info(message, config) do
    Logger.warn("#{__MODULE__} received unexpected message #{message}")
    {:noreply, config}
  end
end
