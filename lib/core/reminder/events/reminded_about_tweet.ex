defmodule Reminder.RemindedAboutTweet do
  use Infrastructure.Schema

  mex_embedded_schema do
    mex_field(:id, Infrastructure.UUID)
    mex_field(:reminder_id, :integer)
  end
end
