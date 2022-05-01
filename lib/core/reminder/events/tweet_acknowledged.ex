defmodule Reminder.TweetAcknowledged do
  use Infrastructure.Schema

  mex_embedded_schema do
    mex_field(:id, Infrastructure.UUID)
    mex_field(:acknowledgement_id, :integer)
  end
end
