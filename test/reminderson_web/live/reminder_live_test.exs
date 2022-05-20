defmodule RemindersonWeb.ReminderLiveTest do
  use RemindersonWeb.ConnCase

  import Phoenix.LiveViewTest
  import Reminderson.RemindersFixtures

  @create_attrs %{acknowledgement_id: 42, ask_reminder_id: 42, ask_reminder_screen_name: "some ask_reminder_screen_name", parsed_text: "some parsed_text", reason_id: 42, reason_screen_name: "some reason_screen_name", reason_text: "some reason_text", remind_at: %{day: 17, hour: 20, minute: 11, month: 5, year: 2022}, reminder_id: 42, tags: [], text: "some text"}
  @update_attrs %{acknowledgement_id: 43, ask_reminder_id: 43, ask_reminder_screen_name: "some updated ask_reminder_screen_name", parsed_text: "some updated parsed_text", reason_id: 43, reason_screen_name: "some updated reason_screen_name", reason_text: "some updated reason_text", remind_at: %{day: 18, hour: 20, minute: 11, month: 5, year: 2022}, reminder_id: 43, tags: [], text: "some updated text"}
  @invalid_attrs %{acknowledgement_id: nil, ask_reminder_id: nil, ask_reminder_screen_name: nil, parsed_text: nil, reason_id: nil, reason_screen_name: nil, reason_text: nil, remind_at: %{day: 30, hour: 20, minute: 11, month: 2, year: 2022}, reminder_id: nil, tags: [], text: nil}

  defp create_reminder(_) do
    reminder = reminder_fixture()
    %{reminder: reminder}
  end

  describe "Index" do
    setup [:create_reminder]

    test "lists all tweet_reminders", %{conn: conn, reminder: reminder} do
      {:ok, _index_live, html} = live(conn, Routes.reminder_index_path(conn, :index))

      assert html =~ "Listing Tweet reminders"
      assert html =~ reminder.ask_reminder_screen_name
    end

    test "saves new reminder", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.reminder_index_path(conn, :index))

      assert index_live |> element("a", "New Reminder") |> render_click() =~
               "New Reminder"

      assert_patch(index_live, Routes.reminder_index_path(conn, :new))

      assert index_live
             |> form("#reminder-form", reminder: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#reminder-form", reminder: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.reminder_index_path(conn, :index))

      assert html =~ "Reminder created successfully"
      assert html =~ "some ask_reminder_screen_name"
    end

    test "updates reminder in listing", %{conn: conn, reminder: reminder} do
      {:ok, index_live, _html} = live(conn, Routes.reminder_index_path(conn, :index))

      assert index_live |> element("#reminder-#{reminder.id} a", "Edit") |> render_click() =~
               "Edit Reminder"

      assert_patch(index_live, Routes.reminder_index_path(conn, :edit, reminder))

      assert index_live
             |> form("#reminder-form", reminder: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#reminder-form", reminder: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.reminder_index_path(conn, :index))

      assert html =~ "Reminder updated successfully"
      assert html =~ "some updated ask_reminder_screen_name"
    end

    test "deletes reminder in listing", %{conn: conn, reminder: reminder} do
      {:ok, index_live, _html} = live(conn, Routes.reminder_index_path(conn, :index))

      assert index_live |> element("#reminder-#{reminder.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#reminder-#{reminder.id}")
    end
  end

  describe "Show" do
    setup [:create_reminder]

    test "displays reminder", %{conn: conn, reminder: reminder} do
      {:ok, _show_live, html} = live(conn, Routes.reminder_show_path(conn, :show, reminder))

      assert html =~ "Show Reminder"
      assert html =~ reminder.ask_reminder_screen_name
    end

    test "updates reminder within modal", %{conn: conn, reminder: reminder} do
      {:ok, show_live, _html} = live(conn, Routes.reminder_show_path(conn, :show, reminder))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Reminder"

      assert_patch(show_live, Routes.reminder_show_path(conn, :edit, reminder))

      assert show_live
             |> form("#reminder-form", reminder: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#reminder-form", reminder: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.reminder_show_path(conn, :show, reminder))

      assert html =~ "Reminder updated successfully"
      assert html =~ "some updated ask_reminder_screen_name"
    end
  end
end
