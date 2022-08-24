defmodule Infrastructure.Twitter.API do
  alias Infrastructure.Twitter.Helper

  @count 200

  def fetch_text_by_id(id) do
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

    [count: @count, since_id: since_id]
    |> ExTwitter.mentions_timeline()
    |> Enum.reject(&is_error?/1)
    |> Enum.reject(&is_author?(&1, account))
    |> Stream.reject(&is_reply_to_author?(&1, account))
    |> Enum.map(&Helper.normalize/1)
    |> then(fn tweets ->
      {tweets, length(tweets) < @count}
    end)
  end

  def fetch_mentions_stream() do
    account = account_to_follow()

    [track: "@" <> "AtgadiniMan"]
    |> ExTwitter.stream_filter(:infinity)
    |> Stream.reject(&is_error?/1)
    |> Stream.reject(&is_author?(&1, account))
    |> Stream.reject(&is_reply_to_author?(&1, account))
    |> Stream.map(&Helper.normalize/1)
  end

  def respond_to_tweet(respond_to, text, opts) do
    ExTwitter.update(
      text,
      in_reply_to_status_id: respond_to,
      quoted_status_id: opts[:quote]
    )
    |> then(&{:ok, Helper.normalize(&1)})
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
    ExTwitter.create_favorite(tweet_id, [])
    |> then(&{:ok, Helper.normalize(&1)})
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

  defp account_to_follow do
    Application.fetch_env!(:extwitter, :oauth)[:account_name]
  end
end
