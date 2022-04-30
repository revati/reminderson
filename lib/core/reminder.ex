defmodule Reminder do
  alias Reminderson.Reminders.TweetTextParser

  defstruct [:id]

  def execute(%__MODULE__{id: nil}, %Reminder.Record{} = command) do
    {:ok, datetime, text, tags} = TweetTextParser.parse(command.text)

    command
    |> Map.from_struct()
    |> Map.put(:tags, tags)
    |> Map.put(:remind_at, datetime)
    |> Map.put(:parsed_text, text)
    |> then(&normalize_reason_params/1)
    |> then(&struct(Reminder.Recorded, &1))
  end

  def execute(%__MODULE__{}, %Reminder.Record{}) do
    {:error, :already_recorded}
  end

  def execute(%__MODULE__{id: id}, %Reminder.StoreReasonText{id: id} = command)
      when not is_nil(id) do
    %Reminder.ReasonTextStored{id: id, reason_text: command.reason_text}
  end

  def apply(%__MODULE__{id: nil} = aggregate, %Reminder.Recorded{id: id} = event) do
    %{aggregate | id: id}
  end

  def apply(%__MODULE__{} = aggregate, %Reminder.ReasonTextStored{}) do
    aggregate
  end

  defp normalize_reason_params(%{reason_id: nil} = params) do
    params
    |> Map.put(:reason_id, params.ask_reminder_id)
    |> Map.put(:reason_screen_name, params.ask_reminder_screen_name)
  end

  defp normalize_reason_params(params) do
    params
  end
end
