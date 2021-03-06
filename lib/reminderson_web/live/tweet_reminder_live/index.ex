defmodule RemindersonWeb.ReminderLive.Index do
  use RemindersonWeb, :live_view

  alias Reminderson.Reminders

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :tweet_reminders, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    changeset = RemindersonWeb.FilterComponent.Form.changeset(params)

    socket
    |> assign(:page_title, "Listing Tweet reminders")
    |> assign(:changeset, changeset)
    |> assign(:tweet_reminders, list_tweet_reminders(changeset))
  end

  defp list_tweet_reminders(changeset) do
    changeset
    |> RemindersonWeb.FilterComponent.Form.to_params()
    |> Reminders.list_tweet_reminders()
  end
end
