defmodule RemindersonWeb.TweetReminderLive.Index do
  use RemindersonWeb, :live_view

  alias Reminderson.Reminders
  alias Reminderson.Reminders.TweetReminder

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :reminders_tweet, list_tweet_reminders())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Tweet reminder")
    |> assign(:tweet_reminder, Reminders.get_tweet_reminder!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Tweet reminder")
    |> assign(:tweet_reminder, %TweetReminder{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Reminders tweet")
    |> assign(:tweet_reminder, nil)
    |> put_flash(:info, "It worked! #{inspect(:rand.uniform(100))}")
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tweet_reminder = Reminders.get_tweet_reminder!(id)
    {:ok, _} = Reminders.delete_tweet_reminder(tweet_reminder)

    {:noreply, assign(socket, :reminders_tweet, list_tweet_reminders())}
  end

  defp list_tweet_reminders do
    Reminders.list_tweet_reminders()
  end
end
