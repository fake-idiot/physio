defmodule Physio.AppointmentsTest do
  use Physio.DataCase

  alias Physio.Appointments

  describe "appointments" do
    alias Physio.Appointments.Appointment

    import Physio.AppointmentsFixtures

    @invalid_attrs %{date: nil, description: nil, time: nil}

    test "list_appointments/0 returns all appointments" do
      appointment = appointment_fixture()
      assert Appointments.list_appointments() == [appointment]
    end

    test "get_appointment!/1 returns the appointment with given id" do
      appointment = appointment_fixture()
      assert Appointments.get_appointment!(appointment.id) == appointment
    end

    test "create_appointment/1 with valid data creates a appointment" do
      valid_attrs = %{date: ~D[2023-05-18], description: "some description", time: ~T[14:00:00]}

      assert {:ok, %Appointment{} = appointment} = Appointments.create_appointment(valid_attrs)
      assert appointment.date == ~D[2023-05-18]
      assert appointment.description == "some description"
      assert appointment.time == ~T[14:00:00]
    end

    test "create_appointment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Appointments.create_appointment(@invalid_attrs)
    end

    test "update_appointment/2 with valid data updates the appointment" do
      appointment = appointment_fixture()
      update_attrs = %{date: ~D[2023-05-19], description: "some updated description", time: ~T[15:01:01]}

      assert {:ok, %Appointment{} = appointment} = Appointments.update_appointment(appointment, update_attrs)
      assert appointment.date == ~D[2023-05-19]
      assert appointment.description == "some updated description"
      assert appointment.time == ~T[15:01:01]
    end

    test "update_appointment/2 with invalid data returns error changeset" do
      appointment = appointment_fixture()
      assert {:error, %Ecto.Changeset{}} = Appointments.update_appointment(appointment, @invalid_attrs)
      assert appointment == Appointments.get_appointment!(appointment.id)
    end

    test "delete_appointment/1 deletes the appointment" do
      appointment = appointment_fixture()
      assert {:ok, %Appointment{}} = Appointments.delete_appointment(appointment)
      assert_raise Ecto.NoResultsError, fn -> Appointments.get_appointment!(appointment.id) end
    end

    test "change_appointment/1 returns a appointment changeset" do
      appointment = appointment_fixture()
      assert %Ecto.Changeset{} = Appointments.change_appointment(appointment)
    end
  end
end
