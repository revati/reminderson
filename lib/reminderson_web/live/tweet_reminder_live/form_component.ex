defmodule RemindersonWeb.TweetReminderLive.FormComponent do
  use RemindersonWeb, :live_component

  alias Reminderson.Reminders

  @impl true
  def update(%{tweet_reminder: tweet_reminder} = assigns, socket) do
    changeset = Reminders.change_tweet_reminder(tweet_reminder)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"tweet_reminder" => tweet_reminder_params}, socket) do
    changeset =
      socket.assigns.tweet_reminder
      |> Reminders.change_tweet_reminder(tweet_reminder_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"tweet_reminder" => tweet_reminder_params}, socket) do
    save_tweet_reminder(socket, socket.assigns.action, tweet_reminder_params)
  end

  defp save_tweet_reminder(socket, :edit, tweet_reminder_params) do
    case Reminders.update_tweet_reminder(socket.assigns.tweet_reminder, tweet_reminder_params) do
      {:ok, _tweet_reminder} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tweet reminder updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_tweet_reminder(socket, :new, tweet_reminder_params) do
    case Reminders.create_tweet_reminder(tweet_reminder_params) do
      {:ok, _tweet_reminder} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tweet reminder created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
