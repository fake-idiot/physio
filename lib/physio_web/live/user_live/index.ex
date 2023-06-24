defmodule PhysioWeb.UserLive.Index do
  use PhysioWeb, :live_view

  alias Physio.Appointments

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_doctor: find_current_doctor(session))
    patients = Appointments.get_patients_by_doctor_id(socket.assigns.current_doctor.id)
    {:ok,
      socket
      |> assign(patients: patients)
    }
  end

  @impl true
  def handle_event("patient_detail", %{"user_id" => user_id}, socket) do
    socket = redirect(socket, to: Routes.user_show_path(socket, :show, user_id))
    {:noreply, socket}
  end
end
