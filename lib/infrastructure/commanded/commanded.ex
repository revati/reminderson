defmodule Infrastructure.Commanded do
  @moduledoc false

  use Commanded.Application,
    otp_app: :reminderson,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: Infrastructure.EventStore
    ]

  router Infrastructure.Router
end
