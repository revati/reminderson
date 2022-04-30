defmodule Reminder.StoreReasonText do
  use Infrastructure.Command

  mex_embedded_schema do
    mex_field(:id, Infrastructure.UUID,
      primary_key: true,
      validation: :required
    )

    mex_field(:reason_text, :string)
  end
end
