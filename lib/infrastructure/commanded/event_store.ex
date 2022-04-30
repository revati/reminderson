defmodule Infrastructure.EventStore do
  @moduledoc false

  use EventStore,
    otp_app: :reminderson,
    serializer: Infrastructure.EventSerializer
end
