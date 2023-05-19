defmodule PhysioWeb.AppointmentLiveTest do
  use PhysioWeb.ConnCase

  import Phoenix.LiveViewTest
  import Physio.AppointmentsFixtures

  @create_attrs %{date: %{day: 18, month: 5, year: 2023}, description: "some description", time: %{hour: 14, minute: 0}}
  @update_attrs %{date: %{day: 19, month: 5, year: 2023}, description: "some updated description", time: %{hour: 15, minute: 1}}
  @invalid_attrs %{date: %{day: 30, month: 2, year: 2023}, description: nil, time: %{hour: 14, minute: 0}}

  defp create_appointment(_) do
    appointment = appointment_fixture()
    %{appointment: appointment}
  end

  describe "Index" do
    setup [:create_appointment]

    test "lists all appointments", %{conn: conn, appointment: appointment} do
      {:ok, _index_live, html} = live(conn, Routes.appointment_index_path(conn, :index))

      assert html =~ "Listing Appointments"
      assert html =~ appointment.description
    end

    test "saves new appointment", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.appointment_index_path(conn, :index))

      assert index_live |> element("a", "New Appointment") |> render_click() =~
               "New Appointment"

      assert_patch(index_live, Routes.appointment_index_path(conn, :new))

      assert index_live
             |> form("#appointment-form", appointment: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#appointment-form", appointment: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.appointment_index_path(conn, :index))

      assert html =~ "Appointment created successfully"
      assert html =~ "some description"
    end

    test "updates appointment in listing", %{conn: conn, appointment: appointment} do
      {:ok, index_live, _html} = live(conn, Routes.appointment_index_path(conn, :index))

      assert index_live |> element("#appointment-#{appointment.id} a", "Edit") |> render_click() =~
               "Edit Appointment"

      assert_patch(index_live, Routes.appointment_index_path(conn, :edit, appointment))

      assert index_live
             |> form("#appointment-form", appointment: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#appointment-form", appointment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.appointment_index_path(conn, :index))

      assert html =~ "Appointment updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes appointment in listing", %{conn: conn, appointment: appointment} do
      {:ok, index_live, _html} = live(conn, Routes.appointment_index_path(conn, :index))

      assert index_live |> element("#appointment-#{appointment.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#appointment-#{appointment.id}")
    end
  end

  describe "Show" do
    setup [:create_appointment]

    test "displays appointment", %{conn: conn, appointment: appointment} do
      {:ok, _show_live, html} = live(conn, Routes.appointment_show_path(conn, :show, appointment))

      assert html =~ "Show Appointment"
      assert html =~ appointment.description
    end

    test "updates appointment within modal", %{conn: conn, appointment: appointment} do
      {:ok, show_live, _html} = live(conn, Routes.appointment_show_path(conn, :show, appointment))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Appointment"

      assert_patch(show_live, Routes.appointment_show_path(conn, :edit, appointment))

      assert show_live
             |> form("#appointment-form", appointment: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#appointment-form", appointment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.appointment_show_path(conn, :show, appointment))

      assert html =~ "Appointment updated successfully"
      assert html =~ "some updated description"
    end
  end
end
