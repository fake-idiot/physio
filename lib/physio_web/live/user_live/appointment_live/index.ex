defmodule PhysioWeb.UserLive.AppointmentLive.Index do
  use PhysioWeb, :live_view

  alias Physio.Appointments
  alias Physio.Accounts
  alias Physio.Prescriptions
  alias Physio.Appointments.Appointment

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_user: find_current_user(session))

    {:ok,
      socket
      |> assign(
        upcoming_appointments: Appointments.upcoming_appointments_by_user_id(socket.assigns.current_user.id),
        outdated_appointments: Appointments.outdated_appointments_by_user_id(socket.assigns.current_user.id),
        open_prescription_modal?: false
      )
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket = assign(socket, :open_prescription_modal?, false)
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Appointment")
    |> assign(:appointment, Appointments.get_appointment!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Appointment")
    |> assign(:appointment, %Appointment{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Appointments")
    |> assign(:appointment, nil)
  end

  @impl true
  def handle_event("show", %{"appointment_id" => appointment_id}, socket) do
    socket =
      assign(
        socket,
        live_action: :show,
        page_title: "Appointment Detail",
        appointment: Appointments.get_appointment!(appointment_id)
      )
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    appointment = Appointments.get_appointment!(id)
    {:ok, _} = Appointments.delete_appointment(appointment)

    {:noreply, assign(socket, :appointments, list_appointments(socket.assigns.current_user.id))}
  end

  def handle_event("view_prescription", %{"appointment_id" => appointment_id}, socket) do
    appointment = Appointments.get_appointment!(appointment_id)
    if appointment.prescription do
      user = Accounts.get_user!(appointment.user_id)
      doctor = Accounts.get_doctor!(appointment.doctor_id)

      socket =
        assign(
          socket,
          live_action: :show_pres,
          open_prescription_modal?: true,
          page_title: "View Prescription",
          appointment: appointment,
          prescription: Prescriptions.get_prescription!(appointment.prescription.id) ,
          user: user,
          doctor: doctor
        )
      {:noreply, socket}
    else
      {:noreply,
        socket
        |> put_flash(:error, "Prescription Not Found")
        |> push_redirect(to: Routes.user_appointment_index_path(socket, :index))
      }
    end
  end

  defp list_appointments(user_id) do
    Appointments.listing_appointments_by_user_id(user_id)
  end
end
