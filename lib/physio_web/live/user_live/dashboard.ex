defmodule PhysioWeb.UserLive.Dashboard do
  use PhysioWeb, :live_view

  alias Physio.Appointments

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_user: find_current_user(session))

    upcoming_appointments = Appointments.upcoming_appointments_by_user_id(socket.assigns.current_user.id)
    appointments = Appointments.listing_appointments_by_user_id(socket.assigns.current_user.id)
    socket =
      assign(
        socket,
        upcoming_appointments: upcoming_appointments,
        appointments: appointments
      )
    {:ok, socket}
  end

  @impl true
  def handle_event("see_all_appointments", _payload, socket) do
    socket = redirect(socket, to: Routes.user_appointment_index_path(socket, :index))
    {:noreply, socket}
  end

end
