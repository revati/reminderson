import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :reminderson, Reminderson.Repo,
  username: "atgadinators",
  password: "secret",
  hostname: "localhost",
  database: "reminderson_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :reminderson, Infrastructure.EventStore,
  username: "atgadinators",
  password: "secret",
  hostname: "localhost",
  database: "reminderson_es_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :reminderson, RemindersonWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "T+9Q55ylBBmTavMqKHpOknWM04t1adZdOlVD9KOW95OmkD6gXm52NJoA3s+moBE1",
  server: false

# In test we don't send emails.
config :reminderson, Reminderson.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
