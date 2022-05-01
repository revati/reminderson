defmodule Reminder.Jobs.FetchReasonTextJob do
  use Oban.Worker, queue: :twitter_bot

  def initiate(id) do
    %{id: id}
    |> __MODULE__.new()
    |> Oban.insert()
  end

  def perform(%Oban.Job{args: %{"id" => id} = _args}) do
    :ok = Core.dispatch(Reminder.FetchTweetReasonText, %{id: id}, %{system: true})
  end
end
