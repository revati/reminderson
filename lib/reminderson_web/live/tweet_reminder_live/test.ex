defmodule RemindersonWeb.ReminderLive.Test do
  use RemindersonWeb, :live_view

  alias Phoenix.LiveView.JS
  alias Reminderson.Reminders

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :test, params) do
    socket
  end
end
