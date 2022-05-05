defmodule Infrastructure.Repo do
  use Boundary, top_level?: true, deps: [Ecto], exports: []

  use Ecto.Repo,
    otp_app: :reminderson,
    adapter: Ecto.Adapters.Postgres
end
