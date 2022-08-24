import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# Start the phoenix server if environment is set and running in a release
if System.get_env("PHX_SERVER") && System.get_env("RELEASE_NAME") do
  config :reminderson, RemindersonWeb.Endpoint, server: true
end

true_values = ["1", 1, "true", true]

config :extwitter, :oauth,
  consumer_key: System.fetch_env!("TWITTER_CONSUMER_KEY"),
  consumer_secret: System.fetch_env!("TWITTER_CONSUMER_SECRET"),
  access_token: System.fetch_env!("TWITTER_ACCESS_TOKEN"),
  access_token_secret: System.fetch_env!("TWITTER_ACCESS_SECRET"),
  account_name: String.downcase(System.fetch_env!("TWITTER_ACCOUNT_TO_FALLOW")),
  connect?: System.fetch_env!("TWITTER_CONNECT") in true_values,
  fetch_past_mentions?: System.fetch_env!("TWITTER_FETCH_PAST_MENTIONS") in true_values,
  send_tweets?: System.fetch_env!("TWITTER_SEND_TWEETS") in true_values

config :sentry,
  dsn: System.fetch_env!("SENTRY_DSN"),
  environment_name: config_env(),
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: "production"
  },
  included_environments: [:prod, :dev]

config :logger,
  backends: [:console, Sentry.LoggerBackend]

if config_env() == :prod do
  database_url =
    System.fetch_env!("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  database_url_reports =
    System.fetch_env!("DATABASE_URL_REPORTS") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  # maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :reminderson, Reminderson.Repo,
    # ssl: true,
    url: database_url_reports,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: [:inet6]

  config :reminderson, Infrastructure.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: [:inet6],
    migration_source: "core_schema_migrations"

  config :reminderson, Infrastructure.EventStore,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: [:inet6]

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  app_name =
    System.get_env("FLY_APP_NAME") ||
      raise "FLY_APP_NAME not available"

  host = System.get_env("PHX_HOST") || "#{app_name}.fly.dev"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :reminderson, RemindersonWeb.Endpoint,
    server: true,
    url: [host: host, port: 80],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  #     config :reminderson, RemindersonWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :reminderson, Reminderson.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
