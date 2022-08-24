defmodule Infrastructure.Twitter.Connect do
  def allowed_to_fetch_tweet?() do
    allowed_to_connect?()
  end

  def allowed_to_fetch_mentions?() do
    true
  end

  def allowed_to_respond? do
    allowed_to_connect?() && Application.fetch_env!(:extwitter, :oauth)[:send_tweets?]
  end

  def allowed_to_fetch_historic_mentions? do
    allowed_to_connect?() && Application.fetch_env!(:extwitter, :oauth)[:fetch_past_mentions?]
  end

  defp allowed_to_connect? do
    Application.fetch_env!(:extwitter, :oauth)[:connect?]
  end
end
