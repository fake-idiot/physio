defmodule Physio.AppointmentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Physio.Appointments` context.
  """

  @doc """
  Generate a appointment.
  """
  def appointment_fixture(attrs \\ %{}) do
    {:ok, appointment} =
      attrs
      |> Enum.into(%{
        date: ~D[2023-05-18],
        description: "some description",
        time: ~T[14:00:00]
      })
      |> Physio.Appointments.create_appointment()

    appointment
  end
end
