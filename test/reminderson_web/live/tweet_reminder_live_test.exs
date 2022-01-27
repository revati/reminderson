defmodule RemindersonWeb.TweetReminderLiveTest do
  use RemindersonWeb.ConnCase

  import Phoenix.LiveViewTest
  import Reminderson.RemindersFixtures

  @create_attrs %{acknowledgement_id: 42, ask_reminder_id: 42, ask_reminder_screen_name: "some ask_reminder_screen_name", reason_id: 42, reason_screen_name: "some reason_screen_name", remind_at: %{day: 26, hour: 20, minute: 32, month: 1, year: 2022}, reminder_id: 42, tags: [], text: "some text"}
  @update_attrs %{acknowledgement_id: 43, ask_reminder_id: 43, ask_reminder_screen_name: "some updated ask_reminder_screen_name", reason_id: 43, reason_screen_name: "some updated reason_screen_name", remind_at: %{day: 27, hour: 20, minute: 32, month: 1, year: 2022}, reminder_id: 43, tags: [], text: "some updated text"}
  @invalid_attrs %{acknowledgement_id: nil, ask_reminder_id: nil, ask_reminder_screen_name: nil, reason_id: nil, reason_screen_name: nil, remind_at: %{day: 30, hour: 20, minute: 32, month: 2, year: 2022}, reminder_id: nil, tags: [], text: nil}

  defp create_tweet_reminder(_) do
    tweet_reminder = tweet_reminder_fixture()
    %{tweet_reminder: tweet_reminder}
  end

  describe "Index" do
    setup [:create_tweet_reminder]

    test "lists all reminders_tweet", %{conn: conn, tweet_reminder: tweet_reminder} do
      {:ok, _index_live, html} = live(conn, Routes.tweet_reminder_index_path(conn, :index))

      assert html =~ "Listing Reminders tweet"
      assert html =~ tweet_reminder.ask_reminder_screen_name
    end

    test "saves new tweet_reminder", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.tweet_reminder_index_path(conn, :index))

      assert index_live |> element("a", "New Tweet reminder") |> render_click() =~
               "New Tweet reminder"

      assert_patch(index_live, Routes.tweet_reminder_index_path(conn, :new))

      assert index_live
             |> form("#tweet_reminder-form", tweet_reminder: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#tweet_reminder-form", tweet_reminder: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.tweet_reminder_index_path(conn, :index))

      assert html =~ "Tweet reminder created successfully"
      assert html =~ "some ask_reminder_screen_name"
    end

    test "updates tweet_reminder in listing", %{conn: conn, tweet_reminder: tweet_reminder} do
      {:ok, index_live, _html} = live(conn, Routes.tweet_reminder_index_path(conn, :index))

      assert index_live |> element("#tweet_reminder-#{tweet_reminder.id} a", "Edit") |> render_click() =~
               "Edit Tweet reminder"

      assert_patch(index_live, Routes.tweet_reminder_index_path(conn, :edit, tweet_reminder))

      assert index_live
             |> form("#tweet_reminder-form", tweet_reminder: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#tweet_reminder-form", tweet_reminder: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.tweet_reminder_index_path(conn, :index))

      assert html =~ "Tweet reminder updated successfully"
      assert html =~ "some updated ask_reminder_screen_name"
    end

    test "deletes tweet_reminder in listing", %{conn: conn, tweet_reminder: tweet_reminder} do
      {:ok, index_live, _html} = live(conn, Routes.tweet_reminder_index_path(conn, :index))

      assert index_live |> element("#tweet_reminder-#{tweet_reminder.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tweet_reminder-#{tweet_reminder.id}")
    end
  end

  describe "Show" do
    setup [:create_tweet_reminder]

    test "displays tweet_reminder", %{conn: conn, tweet_reminder: tweet_reminder} do
      {:ok, _show_live, html} = live(conn, Routes.tweet_reminder_show_path(conn, :show, tweet_reminder))

      assert html =~ "Show Tweet reminder"
      assert html =~ tweet_reminder.ask_reminder_screen_name
    end

    test "updates tweet_reminder within modal", %{conn: conn, tweet_reminder: tweet_reminder} do
      {:ok, show_live, _html} = live(conn, Routes.tweet_reminder_show_path(conn, :show, tweet_reminder))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Tweet reminder"

      assert_patch(show_live, Routes.tweet_reminder_show_path(conn, :edit, tweet_reminder))

      assert show_live
             |> form("#tweet_reminder-form", tweet_reminder: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#tweet_reminder-form", tweet_reminder: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.tweet_reminder_show_path(conn, :show, tweet_reminder))

      assert html =~ "Tweet reminder updated successfully"
      assert html =~ "some updated ask_reminder_screen_name"
    end
  end
end
