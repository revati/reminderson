defmodule Reminder.TwitterSubscriber do
  use GenServer

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    {:ok, nil, {:continue, :subscribe_to_stream}}
  end

  def handle_continue(:subscribe_to_stream, nil) do
    for tweet <- Infrastructure.Twitter.fetch_latest_mentions() do
      handle_raw_tweet(tweet)
    end

    for tweet <- Infrastructure.Twitter.mentions_stream() do
      handle_raw_tweet(tweet)
    end

    {:noreply, %{}}
  end

  defp handle_raw_tweet(tweet) do
    case Infrastructure.dispatch([Reminder.RecordTweet, Reminder.AcknowledgeTweet], tweet, %{
           system: true
         }) do
      {:ok, response} ->
        Logger.info(response)
        :ok

      {:error, response} ->
        response
        |> inspect()
        |> Logger.error()
    end
  end
end
