defmodule Reminder.Jobs.FetchReasonTextJob do
  use Oban.Worker, queue: :twitter_bot

  def perform(%Oban.Job{args: %{"id" => id} = _args}) do
    Infrastructure.dispatch(Reminder.FetchTweetReasonText, %{id: id}, %{system: true})
  end
end
