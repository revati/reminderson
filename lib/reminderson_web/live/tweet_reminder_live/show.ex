defmodule RemindersonWeb.ReminderLive.Show do
  use RemindersonWeb, :live_view

  alias Reminderson.Reminders

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:reminder, Reminders.get_reminder!(id))}
  end

  defp page_title(:show), do: "Show Reminder"
end
