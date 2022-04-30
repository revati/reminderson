defmodule Reminder.ReasonTextFetched do
  use Infrastructure.Schema

  mex_embedded_schema do
    mex_field(:id, Infrastructure.UUID)
    mex_field(:reason_text, :string)
  end
end
