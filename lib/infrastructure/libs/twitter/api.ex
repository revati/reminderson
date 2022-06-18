defmodule Infrastructure.Twitter.Api do
  @count 200

  def get_text_by_id(id) do
    if should_send_twets?() do
      id
      |> ExTwitter.show()
      |> then(fn
        %ExTwitter.Model.Tweet{text: text} ->
          {:ok, text}

        nil ->
          {:error, :not_found}
      end)
    else
      {:ok, ""}
    end
  end

  def fetch_historic_mentions(since_id) do
    if since_id || should_fetch_past_mentions?() do
      account = account_to_follow()

      [count: @count]
      |> then(fn opts ->
        if since_id,
          do: Keyword.put(opts, :since_id, since_id),
          else: opts
      end)
      |> ExTwitter.mentions_timeline()
      |> Enum.reject(&is_error?/1)
      |> Enum.reject(&is_author?(&1, account))
      |> Stream.reject(&is_reply_to_author?(&1, account))
      |> Enum.map(&normalize/1)
    else
      []
    end
    |> then(fn tweets ->
      {tweets, length(tweets) < @count}
    end)
  end

  def mentions_stream() do
    account = account_to_follow()

    [track: "@" <> "AtgadiniMan"]
    |> ExTwitter.stream_filter(:infinity)
    |> Stream.reject(&is_error?/1)
    |> Stream.reject(&is_author?(&1, account))
    |> Stream.reject(&is_reply_to_author?(&1, account))
    |> Stream.map(&normalize/1)
  end

  def respond_to_tweet(respond_to, text, opts \\ []) do
    if should_send_twets?() do
      ExTwitter.update(
        text,
        in_reply_to_status_id: respond_to,
        quoted_status_id: opts[:quote]
      )
      |> then(&{:ok, normalize(&1)})
    else
      [respond_to: respond_to, text: text]
      |> generate_fake_tweet()
      |> then(&{:ok, normalize(&1)})
    end
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

  def like_a_tweet(tweet_id) do
    if should_send_twets?() do
      ExTwitter.create_favorite(tweet_id, [])
      |> then(&{:ok, normalize(&1)})
    else
      [id: tweet_id]
      |> generate_fake_tweet()
      |> then(&{:ok, normalize(&1)})
    end
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

  defp is_reply_to_author?(%ExTwitter.Model.Tweet{} = raw_tweet, account_to_follow) do
    raw_tweet.in_reply_to_status_id &&
      String.downcase(raw_tweet.in_reply_to_screen_name) == account_to_follow
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

  defp account_to_follow do
    Application.fetch_env!(:extwitter, :oauth)[:account_name]
  end

  defp should_send_twets? do
    Application.fetch_env!(:extwitter, :oauth)[:send_tweets?]
  end

  defp should_fetch_past_mentions? do
    Application.fetch_env!(:extwitter, :oauth)[:fetch_past_mentions?]
  end

  defp generate_fake_tweet(opts) do
    id = opts[:id] || :rand.uniform(8_999_999_999_999_999_999) + 1_000_000_000_000_000_00

    %ExTwitter.Model.Tweet{
      id: id,
      text: opts[:text] || "whatever",
      user: %{screen_name: "test"},
      in_reply_to_status_id: opts[:respond_to],
      in_reply_to_screen_name: "another",
      created_at: "Wed Sep 14 16:50:47 +0000 2011"
    }
  end
end
