defmodule RemindersonWeb.TweetReminderLive.Show do
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
     |> assign(:tweet_reminder, Reminders.get_tweet_reminder!(id))}
  end

  defp page_title(:show), do: "Show Tweet reminder"
  defp page_title(:edit), do: "Edit Tweet reminder"
end
