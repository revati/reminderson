defmodule Reminder.Aggregate do
  defstruct [:id, :reason_id]

  def execute(%__MODULE__{id: nil}, %Reminder.RecordTweet{} = command) do
    {:ok, datetime, text, tags} = Twitter.parse(command.text)

    command
    |> Map.from_struct()
    |> Map.put(:tags, tags)
    |> Map.put(:remind_at, datetime)
    |> Map.put(:parsed_text, text)
    |> then(&normalize_reason_params/1)
    |> then(&struct(Reminder.TweetRecorded, &1))
  end

  def execute(%__MODULE__{}, %Reminder.RecordTweet{}) do
    {:error, :already_recorded}
  end

  def execute(%__MODULE__{id: nil}, %Reminder.FetchReasonText{}) do
    {:error, :not_found}
  end

  def execute(%__MODULE__{id: id} = aggregate, %Reminder.FetchReasonText{}) do
    case aggregate do
      %{has_reason_text?: true} ->
        :ok

      %{ask_reminder_id: id, reason_id: id} ->
        :ok

      %{reason_id: reason_id} ->
        case Twitter.get_text_by_id(reason_id) do
          {:ok, text} -> %Reminder.ReasonTextFetched{id: id, reason_text: text}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  def apply(%__MODULE__{id: nil} = aggregate, %Reminder.TweetRecorded{} = event) do
    %{aggregate | id: event.id, reason_id: event.reason_id}
  end

  def apply(%__MODULE__{} = aggregate, %Reminder.ReasonTextFetched{}) do
    aggregate
  end

  defp normalize_reason_params(%{reason_id: nil} = params) do
    params
    |> Map.put(:reason_id, params.ask_reminder_id)
    |> Map.put(:reason_screen_name, params.ask_reminder_screen_name)
    |> Map.put(:reason_text, params.text)
  end

  defp normalize_reason_params(params) do
    params
  end
end
