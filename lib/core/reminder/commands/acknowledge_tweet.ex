defmodule Reminder.AcknowledgeTweet do
  use Infrastructure.Command

  mex_embedded_schema do
    mex_field(:id, Infrastructure.UUID,
      primary_key: true,
      validation: :required
    )
  end
end
