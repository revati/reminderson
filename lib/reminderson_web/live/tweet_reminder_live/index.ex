defmodule RemindersonWeb.ReminderLive.Index do
  use RemindersonWeb, :live_view

  alias Reminderson.Reminders

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :tweet_reminders, list_tweet_reminders())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tweet reminders")
    |> assign(:reminder, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    reminder = Reminders.get_reminder!(id)
    {:ok, _} = Reminders.delete_reminder(reminder)

    {:noreply, assign(socket, :tweet_reminders, list_tweet_reminders())}
  end

  defp list_tweet_reminders do
    Reminders.list_tweet_reminders()
  end
end
