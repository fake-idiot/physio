defmodule PhysioWeb.DoctorLive.DoctorAppointment do
  use PhysioWeb, :live_view

  alias Physio.Appointments

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_doctor: find_current_doctor(session))

    {:ok,
      socket
      |> assign(
        upcoming_appointments: Appointments.upcoming_appointments_by_doctor_id(socket.assigns.current_doctor.id),
        outdated_appointments: Appointments.outdated_appointments_by_doctor_id(socket.assigns.current_doctor.id)
      )
    }
  end
end
