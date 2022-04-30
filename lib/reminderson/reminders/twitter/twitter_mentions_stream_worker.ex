defmodule Reminderson.Reminders.TwitterMentionsStreamWorker do
  use GenServer

  alias Reminderson.Reminders.Twitter, as: RTwitter
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
      RTwitter.get_last_reminder()
      |> case do
        nil ->
          [count: 1]

        %TweetReminder{} = reminder ->
          [count: 1, since_id: reminder.ask_reminder_id]
      end
      |> then(fn timeline ->
        for tweet <- ExTwitter.mentions_timeline(timeline) do
          handle_raw_tweet(tweet, config)
        end
      end)
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
      payload = extract_from_raw_tweet(raw_tweet) |> IO.inspect()

      :ok = Core.dispatch(Reminder.RecordTweet, payload, %{system: true})
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
    IO.puts(message, label: :handle_raw_tweet)
  end

  def handle_info(message, config) do
    Logger.warn("#{__MODULE__} received unexpected message #{message}")
    {:noreply, config}
  end

  defp extract_from_raw_tweet(%RawTweet{} = reminder) do
    # {:ok, datetime, text, tags} = Twitter.parse(reminder.text)

    # datetime =
    #   if is_nil(datetime),
    #     do: nil,
    #     else: datetime |> Timex.Timezone.convert("Etc/UTC") |> DateTime.to_naive()

    %{
      # type: :tweet,
      text: reminder.text,
      reason_text: extract_reason_text(reminder),
      # tags: tags,
      # remind_at: datetime,
      ask_reminder_id: reminder.id,
      ask_reminder_screen_name: reminder.user.screen_name,
      reason_id: reminder.in_reply_to_status_id,
      reason_screen_name: reminder.in_reply_to_screen_name
    }
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
