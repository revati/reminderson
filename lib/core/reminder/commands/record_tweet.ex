defmodule Reminder.RecordTweet do
  use Infrastructure.Command

  mex_embedded_schema do
    mex_field(:id, Infrastructure.UUID,
      primary_key: true,
      autogenerate: true,
      validation: :required
    )

    mex_field(:text, :string)
    mex_field(:ask_reminder_id, :integer, validation: :required)
    mex_field(:ask_reminder_screen_name, :string, validation: :required)
    mex_field(:reason_id, :integer, validation: [required_if: :reason_screen_name])
    mex_field(:reason_screen_name, :string, validation: [required_if: :reason_id])
  end
end
