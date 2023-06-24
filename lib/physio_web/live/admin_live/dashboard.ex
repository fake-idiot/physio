defmodule PhysioWeb.AdminLive.Dashboard do
  use PhysioWeb, :live_view

  alias Physio.Accounts
  alias Physio.Appointments

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_admin: find_current_admin(session))
    doctors = Accounts.list_doctor()
    patients = Accounts.list_users()
    appointments = Appointments.list_appointments()
    {:ok,
      socket
      |> assign(
        doctors: doctors,
        patients: patients,
        appointments: appointments
      )
    }
  end
end
