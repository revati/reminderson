defmodule Reminder.RecordTweet do
  use Infrastructure.Command

  @unique {:unique, [model: Reminder.State, ignore_same_id?: true]}

  mex_embedded_schema do
    mex_field(:id, Infrastructure.UUID,
      primary_key: true,
      autogenerate: true,
      validation: :required
    )

    mex_field(:text, :string)
    mex_field(:ask_reminder_id, :integer, validation: [:required, @unique])
    mex_field(:ask_reminder_screen_name, :string, validation: :required)
    mex_field(:respond_to_id, :integer, validation: [required_if: :respond_to_screen_name])
    mex_field(:respond_to_screen_name, :string, validation: [required_if: :respond_to_id])
    mex_field(:quote_id, :integer, validation: [required_if: :quote_screen_name])
    mex_field(:quote_screen_name, :string, validation: [required_if: :quote_id])
    mex_field(:created_at, :utc_datetime, validation: :required)
  end
end
