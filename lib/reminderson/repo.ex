defmodule Reminderson.Repo do
  use Ecto.Repo,
    otp_app: :reminderson,
    adapter: Ecto.Adapters.Postgres
end
