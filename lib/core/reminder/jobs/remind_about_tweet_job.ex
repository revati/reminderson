defmodule Reminder.Jobs.RemindAboutTweetJob do
  use Oban.Worker, queue: :twitter_bot

  def perform(%Oban.Job{args: %{"id" => id} = _args}) do
    Infrastructure.dispatch(Reminder.RemindAboutTweet, %{id: id}, %{system: true})
  end
end
