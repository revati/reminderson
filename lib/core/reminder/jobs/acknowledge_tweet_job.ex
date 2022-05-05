defmodule Reminder.Jobs.AcknowledgeTweetJob do
  use Oban.Worker, queue: :twitter_bot

  def perform(%Oban.Job{args: %{"id" => id} = _args}) do
    :ok = Infrastructure.dispatch(Reminder.AcknowledgeTweet, %{id: id}, %{system: true})
  end
end
