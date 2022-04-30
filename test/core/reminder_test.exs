defmodule ReminderTest do
  use Reminderson.DataCase

  test "can record new reminder" do
    params = %{
      reason_screen_name: "reason_test",
      reason_id: :rand.uniform(100),
      ask_reminder_screen_name: "ask_test",
      ask_reminder_id: :rand.uniform(100),
      text: "sd"
    }

    assert :ok = Reminderson.dispatch(Reminder.Record, params, %{})
  end
end
