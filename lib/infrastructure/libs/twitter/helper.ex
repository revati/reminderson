defmodule Infrastructure.Twitter.Helper do
  alias ExTwitter.Model.Tweet

  def normalize(%Tweet{} = tweet) do
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
end
