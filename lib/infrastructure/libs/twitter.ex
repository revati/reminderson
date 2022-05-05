defmodule Infrastructure.Twitter do
  use Boundary, top_level?: true, deps: [ExTwitter], exports: []

  defdelegate parse(text, relative_date), to: Infrastructure.Twitter.Parser

  defdelegate get_text_by_id(id), to: Infrastructure.Twitter.Api
  defdelegate fetch_latest_mentions(since_id \\ nil), to: Infrastructure.Twitter.Api
  defdelegate mentions_stream(), to: Infrastructure.Twitter.Api
  defdelegate respond_to_tweet(respond_to, text, opts \\ []), to: Infrastructure.Twitter.Api
end
