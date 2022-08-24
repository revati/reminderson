defmodule Infrastructure.Twitter.Faker do
  alias Infrastructure.Twitter.Helper

  def generate_fake_tweet(opts) do
    id = opts[:id] || :rand.uniform(8_999_999_999_999_999_999) + 1_000_000_000_000_000_00

    %ExTwitter.Model.Tweet{
      id: id,
      text: opts[:text] || "whatever",
      user: %{screen_name: "test"},
      in_reply_to_status_id: opts[:respond_to],
      in_reply_to_screen_name: "another",
      created_at: "Wed Sep 14 16:50:47 +0000 2011"
    }
    |> Helper.normalize()
  end
end
