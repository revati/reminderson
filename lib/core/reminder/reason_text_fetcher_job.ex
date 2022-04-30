defmodule Reminder.ReasonTextFetcherJob do
  use Oban.Worker, queue: :twitter_bot

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id} = _args} = job) do
    meta = %{system: true}

    Reminder.FetchReasonText
    |> Core.dispatch(%{id: id}, meta)
    |> case do
      :ok ->
        :ok

      error ->
        if job.attempt < job.max_attempts do
          error
        else
          :ok
        end
    end
  end
end
