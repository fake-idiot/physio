defmodule PhysioWeb.UserLive.Dashboard do
  use PhysioWeb, :live_view

  alias Physio.Accounts
  alias Physio.Appointments
  alias Physio.Prescriptions

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_user: find_current_user(session))

    upcoming_appointments = Appointments.upcoming_appointments_by_user_id(socket.assigns.current_user.id)
    appointments = Appointments.listing_appointments_by_user_id(socket.assigns.current_user.id)
    today_appointments = Appointments.today_appointments_by_user_id(socket.assigns.current_user.id)
    prescriptions = Prescriptions.get_prescriptions_by_user_id(socket.assigns.current_user.id)
    socket =
      assign(
        socket,
        upcoming_appointments: upcoming_appointments,
        appointments: appointments,
        today_appointments: today_appointments,
        prescriptions: prescriptions,
        open_prescription_modal?: false
      )
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket =
      assign(
        socket,
        open_prescription_modal?: false
      )
    {:noreply, socket}
  end

  @impl true
  def handle_event("see_all_appointments", _payload, socket) do
    socket = redirect(socket, to: Routes.user_appointment_index_path(socket, :index))
    {:noreply, socket}
  end

  @impl true
  def handle_event("view_prescription", %{"prescription_id" => prescription_id}, socket) do
    prescription = Prescriptions.get_prescription!(prescription_id)
    if prescription do
      doctor = Accounts.get_doctor!(prescription.doctor_id)
      appointment = Appointments.get_appointment!(prescription.appointment_id)

      socket =
        assign(
          socket,
          live_action: :show,
          open_prescription_modal?: true,
          page_title: "View Prescription",
          appointment: appointment,
          prescription: Prescriptions.get_prescription!(prescription_id) ,
          doctor: doctor
        )
      {:noreply, socket}
    else
      {:noreply,
        socket
        |> put_flash(:error, "Prescription Not Found")
        |> push_redirect(to: Routes.user_dashboard_path(socket, :dashboard))
      }
    end
  end

end
