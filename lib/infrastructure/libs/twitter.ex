defmodule Infrastructure.Twitter do
  use Boundary, top_level?: true, deps: [ExTwitter], exports: []
  alias Infrastructure.Twitter.{API, Connect, Faker}

  defdelegate parse(text, relative_date), to: Infrastructure.Twitter.Parser

  def fetch_text_by_id(id) do
    if Connect.allowed_to_fetch_tweet?(),
      do: API.fetch_text_by_id(id),
      else: {:ok, ""}
  end

  def fetch_historic_mentions(since_id) do
    if since_id && Connect.allowed_to_fetch_historic_mentions?(),
      do: API.fetch_historic_mentions(since_id),
      else: {[], _end_reached? = true}
  end

  def fetch_mentions_stream() do
    if Connect.allowed_to_fetch_mentions?(),
      do: API.fetch_mentions_stream(),
      else: []
  end

  def respond_to_tweet(respond_to, text, opts \\ []) do
    if Connect.allowed_to_respond?(),
      do: API.respond_to_tweet(respond_to, text, opts),
      else: {:ok, Faker.generate_fake_tweet(respond_to: respond_to, text: text)}
  end

  def like_a_tweet(tweet_id) do
    if Connect.allowed_to_respond?(),
      do: API.like_a_tweet(tweet_id),
      else: {:ok, Faker.generate_fake_tweet(id: tweet_id)}
  end
end
