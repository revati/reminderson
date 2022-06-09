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
    params =
      params
      |> RemindersonWeb.FilterComponent.Form.changeset()
      |> Ecto.Changeset.apply_changes()
      |> Map.from_struct()

    socket
    |> assign(:page_title, "Listing Tweet reminders")
    |> assign(:params, params)
    |> assign(:tweet_reminders, list_tweet_reminders(params))
  end

  defp list_tweet_reminders(params) do
    Reminders.list_tweet_reminders(params)
  end
end
