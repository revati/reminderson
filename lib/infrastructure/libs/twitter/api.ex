defmodule Infrastructure.Twitter.Api do
  def get_text_by_id(id) do
    id
    |> ExTwitter.show()
    |> then(fn
      %ExTwitter.Model.Tweet{text: text} ->
        {:ok, text}

      nil ->
        {:error, :not_found}
    end)
  end

  def fetch_historic_mentions(since_id) do
    account = account_to_follow()
    count = 200

    [count: count]
    |> then(fn opts ->
      if since_id,
        do: Keyword.put(opts, :since_id, since_id),
        else: opts
    end)
    |> ExTwitter.mentions_timeline()
    |> Enum.reject(&is_error?/1)
    |> Enum.reject(&is_author?(&1, account))
    |> Enum.map(&normalize/1)
    |> then(fn tweets ->
      {tweets, length(tweets) < count}
    end)
  end

  def mentions_stream() do
    account = account_to_follow()

    [track: "@" <> "AtgadiniMan"]
    |> ExTwitter.stream_filter(:infinity)
    |> Stream.reject(&is_error?/1)
    |> Stream.reject(&is_author?(&1, account))
    |> Stream.map(&normalize/1)
  end

  def respond_to_tweet(respond_to, text, _opts \\ []) do
    # ExTwitter.update(
    #   text,
    #   in_reply_to_status_id: respond_to,
    #   quoted_status_id: opts[:quote]
    # )

    id = :rand.uniform(8_999_999_999_999_999_999) + 1_000_000_000_000_000_000

    %ExTwitter.Model.Tweet{
      id: id,
      text: text,
      user: %{screen_name: "test"},
      in_reply_to_status_id: respond_to,
      in_reply_to_screen_name: "another",
      created_at: "Wed Sep 14 16:50:47 +0000 2011"
    }
    |> then(&{:ok, normalize(&1)})
  rescue
    e in ExTwitter.Error ->
      {:error, %{type: :error, code: e.code, message: e.message}}

    e in ExTwitter.ConnectionError ->
      {:error, %{type: :connection, reason: e.reason, message: e.message}}

    e in ExTwitter.RateLimitExceededError ->
      error = %{
        type: :limit,
        code: e.code,
        message: e.message,
        reset_in: e.reset_in,
        reset_at: e.reset_at
      }

      {:error, error}
  end

  defp is_error?(%ExTwitter.Model.Tweet{}), do: false

  defp is_error?(%ExTwitter.Model.DeletedTweet{} = deleted_tweet) do
    # TODO: mark reminder as deleted and remove reminder worker
    IO.puts("deleted tweet = #{deleted_tweet.status[:id]}")

    true
  end

  defp is_error?(%ExTwitter.Model.Limit{} = limit) do
    IO.puts("limit = #{limit.track}")

    true
  end

  defp is_error?(%ExTwitter.Model.StallWarning{} = stall_warning) do
    IO.puts("stall warning = #{stall_warning.code}")

    true
  end

  defp is_author?(%ExTwitter.Model.Tweet{} = raw_tweet, account_to_follow) do
    String.downcase(raw_tweet.user.screen_name) == account_to_follow
  end

  defp normalize(%ExTwitter.Model.Tweet{} = tweet) do
    %{
      tweet_id: tweet.id,
      text: tweet.text,
      ask_reminder_id: tweet.id,
      ask_reminder_screen_name: tweet.user.screen_name,
      reason_id: tweet.in_reply_to_status_id,
      reason_screen_name: tweet.in_reply_to_status_id && tweet.in_reply_to_screen_name,
      created_at: Timex.parse!(tweet.created_at, "%a %b %d %H:%M:%S %z %Y", :strftime)
    }
  end

  defp account_to_follow() do
    Application.fetch_env!(:extwitter, :oauth)[:account_name]
  end
end
