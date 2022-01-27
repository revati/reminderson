defmodule Reminderson.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Reminderson.Repo,
      # Start the Telemetry supervisor
      RemindersonWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Reminderson.PubSub},
      # Start the Endpoint (http/https)
      RemindersonWeb.Endpoint,
      {Oban, Application.fetch_env!(:reminderson, Oban)},
      {Reminderson.Reminders.TwitterMentionsStreamJob, Application.fetch_env!(:extwitter, :oauth)}
      # Start a worker by calling: Reminderson.Worker.start_link(arg)
      # {Reminderson.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Reminderson.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RemindersonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
