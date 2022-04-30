defmodule Reminder.ReasonTextFetcherJob do
  use Oban.Worker, queue: :twitter_bot

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id, "reason_id" => reason_id} = _args} = job) do
    meta = %{system: true}

    reason_id
    |> ExTwitter.show()
    |> then(fn
      %{text: text} ->
        text

      error ->
        if job.attempt < job.max_attempts do
          raise error
        else
          "Error fetching reason tweet text"
        end
    end)
    |> then(&Reminderson.dispatch(Reminder.StoreReasonText, %{id: id, reason_text: &1}, meta))
  end
end
