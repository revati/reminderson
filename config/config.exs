# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :reminderson,
  ecto_repos: [Reminderson.Repo],
  generators: [binary_id: true]

config :reminderson, Components,
  components: [
    alert: Components.Bootstrap.Alert
    # accordion: HelloWorldWeb.Bootstrap,
    # badge: HelloWorldWeb.Bootstrap,
    # button: Components.Bootstrap.Button,
    # button_group: {Components.Bootstrap.Button, :group},
    # button_toolbar: {Components.Bootstrap.Button, :toolbar},
    # dropdown: Components.Bootstrap.Dropdown,
    # dropdown_toggle: {Components.Bootstrap.Dropdown, :toggle},
    # dropdown_menu: {Components.Bootstrap.Dropdown, :menu}
  ],
  actions: [
    do_click: Components.Bootstrap.Actions,
    do_toggle: Components.Bootstrap.Actions
  ]

config :reminderson, Oban,
  repo: Reminderson.Repo,
  plugins: [
    Oban.Plugins.Stager,
    # Oban.Plugins.Repeater,
    {Oban.Plugins.Pruner, max_age: 300}
  ],
  queues: [twitter_bot: 1]

# Configures the endpoint
config :reminderson, RemindersonWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: RemindersonWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Reminderson.PubSub,
  live_view: [signing_salt: "h3dLfbpV"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :reminderson, Reminderson.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
