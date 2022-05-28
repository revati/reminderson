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
    :ok = fetch_mentions_till_now()
    :ok = subscribe_to_ongoing_mentions()

    {:noreply, %{}}
  end

  # Recursive, as per one request can fetch only 100
  defp fetch_mentions_till_now() do
    {tweets, end_reached?} =
      Reminder.Repo.get_latest_ask_id()
      |> Infrastructure.Twitter.fetch_historic_mentions()

    for tweet <- tweets do
      handle_raw_tweet(tweet)
    end

    if end_reached?, do: :ok, else: fetch_mentions_till_now()
  end

  defp subscribe_to_ongoing_mentions() do
    for tweet <- Infrastructure.Twitter.mentions_stream() do
      handle_raw_tweet(tweet)
    end

    :ok
  end

  defp handle_raw_tweet(tweet) do
    case Infrastructure.dispatch(Reminder.RecordTweet, tweet, %{
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
