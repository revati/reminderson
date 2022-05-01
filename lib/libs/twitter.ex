defmodule Twitter do
  use Boundary, deps: [ExTwitter], exports: []

  defdelegate parse(text, relative_date), to: Twitter.Parser

  defdelegate get_text_by_id(id), to: Twitter.Api
  defdelegate fetch_latest_mentions(since_id \\ nil), to: Twitter.Api
  defdelegate mentions_stream(), to: Twitter.Api
  defdelegate respond_to_tweet(respond_to, text, opts \\ []), to: Twitter.Api
end
