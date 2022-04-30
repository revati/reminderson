defmodule Reminder.TweetRecorded do
  use Infrastructure.Schema

  mex_embedded_schema do
    mex_field(:id, Infrastructure.UUID)
    mex_field(:text, :string)
    mex_field(:parsed_text, :string)
    mex_field(:tags, {:array, :string})
    mex_field(:remind_at, :utc_datetime)
    mex_field(:ask_reminder_id, :integer)
    mex_field(:ask_reminder_screen_name, :string)
    mex_field(:reason_id, :integer)
    mex_field(:reason_screen_name, :string)
    mex_field(:reason_text, :string)
  end
end
