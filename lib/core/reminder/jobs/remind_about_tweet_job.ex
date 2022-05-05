defmodule Reminder.Jobs.RemindAboutTweetJob do
  use Oban.Worker, queue: :twitter_bot

  def initiate(_id, nil) do
    {:ok, nil}
  end

  def initiate(id, remind_at) do
    %{id: id}
    |> __MODULE__.new(scheduled_at: remind_at)
    |> Oban.insert()
  end

  def perform(%Oban.Job{args: %{"id" => id} = _args}) do
    :ok = Infrastructure.dispatch(Reminder.RemindAboutTweet, %{id: id}, %{system: true})
  end
end
