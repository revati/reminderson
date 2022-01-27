defmodule Reminderson.RemindersTest do
  use Reminderson.DataCase

  alias Reminderson.Reminders

  describe "reminders_tweet" do
    alias Reminderson.Reminders.TweetReminder

    import Reminderson.RemindersFixtures

    @invalid_attrs %{
      acknowledgement_id: nil,
      ask_reminder_id: nil,
      ask_reminder_screen_name: nil,
      reason_id: nil,
      reason_screen_name: nil,
      remind_at: nil,
      reminder_id: nil,
      tags: nil,
      text: nil
    }

    test "list_tweet_reminders/0 returns all reminders_tweet" do
      tweet_reminder = tweet_reminder_fixture()
      assert Reminders.list_tweet_reminders() == [tweet_reminder]
    end

    test "get_tweet_reminder!/1 returns the tweet_reminder with given id" do
      tweet_reminder = tweet_reminder_fixture()
      assert Reminders.get_tweet_reminder!(tweet_reminder.id) == tweet_reminder
    end

    test "create_tweet_reminder/1 with valid data creates a tweet_reminder" do
      valid_attrs = %{
        acknowledgement_id: 42,
        ask_reminder_id: 42,
        ask_reminder_screen_name: "some ask_reminder_screen_name",
        reason_id: 42,
        reason_screen_name: "some reason_screen_name",
        remind_at: ~N[2022-01-26 20:32:00],
        reminder_id: 42,
        tags: [],
        text: "some text"
      }

      assert {:ok, %TweetReminder{} = tweet_reminder} =
               Reminders.create_tweet_reminder(valid_attrs)

      assert tweet_reminder.acknowledgement_id == 42
      assert tweet_reminder.ask_reminder_id == 42
      assert tweet_reminder.ask_reminder_screen_name == "some ask_reminder_screen_name"
      assert tweet_reminder.reason_id == 42
      assert tweet_reminder.reason_screen_name == "some reason_screen_name"
      assert tweet_reminder.remind_at == ~N[2022-01-26 20:32:00]
      assert tweet_reminder.reminder_id == 42
      assert tweet_reminder.tags == []
      assert tweet_reminder.text == "some text"
    end

    test "create_tweet_reminder/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reminders.create_tweet_reminder(@invalid_attrs)
    end

    test "update_tweet_reminder/2 with valid data updates the tweet_reminder" do
      tweet_reminder = tweet_reminder_fixture()

      update_attrs = %{
        acknowledgement_id: 43,
        ask_reminder_id: 43,
        ask_reminder_screen_name: "some updated ask_reminder_screen_name",
        reason_id: 43,
        reason_screen_name: "some updated reason_screen_name",
        remind_at: ~N[2022-01-27 20:32:00],
        reminder_id: 43,
        tags: [],
        text: "some updated text"
      }

      assert {:ok, %TweetReminder{} = tweet_reminder} =
               Reminders.update_tweet_reminder(tweet_reminder, update_attrs)

      assert tweet_reminder.acknowledgement_id == 43
      assert tweet_reminder.ask_reminder_id == 43
      assert tweet_reminder.ask_reminder_screen_name == "some updated ask_reminder_screen_name"
      assert tweet_reminder.reason_id == 43
      assert tweet_reminder.reason_screen_name == "some updated reason_screen_name"
      assert tweet_reminder.remind_at == ~N[2022-01-27 20:32:00]
      assert tweet_reminder.reminder_id == 43
      assert tweet_reminder.tags == []
      assert tweet_reminder.text == "some updated text"
    end

    test "update_tweet_reminder/2 with invalid data returns error changeset" do
      tweet_reminder = tweet_reminder_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Reminders.update_tweet_reminder(tweet_reminder, @invalid_attrs)

      assert tweet_reminder == Reminders.get_tweet_reminder!(tweet_reminder.id)
    end

    test "delete_tweet_reminder/1 deletes the tweet_reminder" do
      tweet_reminder = tweet_reminder_fixture()
      assert {:ok, %TweetReminder{}} = Reminders.delete_tweet_reminder(tweet_reminder)
      assert_raise Ecto.NoResultsError, fn -> Reminders.get_tweet_reminder!(tweet_reminder.id) end
    end

    test "change_tweet_reminder/1 returns a tweet_reminder changeset" do
      tweet_reminder = tweet_reminder_fixture()
      assert %Ecto.Changeset{} = Reminders.change_tweet_reminder(tweet_reminder)
    end
  end
end
