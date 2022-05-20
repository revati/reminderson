defmodule Reminderson.RemindersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Reminderson.Reminders` context.
  """

  @doc """
  Generate a unique tweet_reminder acknowledgement_id.
  """
  def unique_tweet_reminder_acknowledgement_id, do: System.unique_integer([:positive])

  @doc """
  Generate a unique tweet_reminder ask_reminder_id.
  """
  def unique_tweet_reminder_ask_reminder_id, do: System.unique_integer([:positive])

  @doc """
  Generate a unique tweet_reminder reminder_id.
  """
  def unique_tweet_reminder_reminder_id, do: System.unique_integer([:positive])

  @doc """
  Generate a tweet_reminder.
  """
  def tweet_reminder_fixture(attrs \\ %{}) do
    {:ok, tweet_reminder} =
      attrs
      |> Enum.into(%{
        acknowledgement_id: unique_tweet_reminder_acknowledgement_id(),
        ask_reminder_id: unique_tweet_reminder_ask_reminder_id(),
        ask_reminder_screen_name: "some ask_reminder_screen_name",
        reason_id: 42,
        reason_screen_name: "some reason_screen_name",
        remind_at: ~N[2022-01-26 20:32:00],
        reminder_id: unique_tweet_reminder_reminder_id(),
        tags: [],
        text: "some text"
      })
      |> Reminderson.Reminders.create_tweet_reminder()

    tweet_reminder
  end

  @doc """
  Generate a unique reminder acknowledgement_id.
  """
  def unique_reminder_acknowledgement_id, do: System.unique_integer([:positive])

  @doc """
  Generate a unique reminder ask_reminder_id.
  """
  def unique_reminder_ask_reminder_id, do: System.unique_integer([:positive])

  @doc """
  Generate a unique reminder reminder_id.
  """
  def unique_reminder_reminder_id, do: System.unique_integer([:positive])

  @doc """
  Generate a reminder.
  """
  def reminder_fixture(attrs \\ %{}) do
    {:ok, reminder} =
      attrs
      |> Enum.into(%{
        acknowledgement_id: unique_reminder_acknowledgement_id(),
        ask_reminder_id: unique_reminder_ask_reminder_id(),
        ask_reminder_screen_name: "some ask_reminder_screen_name",
        parsed_text: "some parsed_text",
        reason_id: 42,
        reason_screen_name: "some reason_screen_name",
        reason_text: "some reason_text",
        remind_at: ~U[2022-05-17 20:11:00Z],
        reminder_id: unique_reminder_reminder_id(),
        tags: [],
        text: "some text"
      })
      |> Reminderson.Reminders.create_reminder()

    reminder
  end
end
