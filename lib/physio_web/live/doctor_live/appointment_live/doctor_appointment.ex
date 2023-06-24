defmodule PhysioWeb.DoctorLive.DoctorAppointment do
  use PhysioWeb, :live_view

  alias Physio.Prescriptions
  alias Physio.Appointments
  alias Physio.Accounts

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_doctor: find_current_doctor(session))

    {:ok,
      socket
      |> assign(
        upcoming_appointments: Appointments.upcoming_appointments_by_doctor_id(socket.assigns.current_doctor.id),
        outdated_appointments: Appointments.outdated_appointments_by_doctor_id(socket.assigns.current_doctor.id),
        open_appointment_modal?: false,
        open_prescription_modal?: false
      )
    }
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket =
      assign(
        socket,
        open_appointment_modal?: false,
        open_prescription_modal?: false
      )
    {:noreply, socket}
  end

  @impl true
  def handle_event("show", %{"appointment_id" => appointment_id}, socket) do
    appointment = Appointments.get_appointment!(appointment_id)
    user = Accounts.get_user!(appointment.user_id)
    socket =
      assign(
        socket,
        live_action: :show,
        open_appointment_modal?: true,
        page_title: "Appointment Detail",
        appointment: appointment,
        user: user
      )
    {:noreply, socket}
  end

  def handle_event("add_prescription", %{"appointment_id" => appointment_id}, socket) do
    appointment = Appointments.get_appointment!(appointment_id)
    user = Accounts.get_user!(appointment.user_id)

    socket =
    if appointment.prescription do
      socket
      |> put_flash(:error, "Prescription already exist against this Appointment")
      |> push_redirect(to: Routes.doctor_doctor_appointment_path(socket, :appointment))
    else
        assign(
          socket,
          live_action: :new,
          open_prescription_modal?: true,
          page_title: "Add Prescription",
          appointment: appointment,
          prescription: %Physio.Prescriptions.Prescription{},
          user: user
        )
    end
    {:noreply, socket}
  end

  def handle_event("view_prescription", %{"appointment_id" => appointment_id}, socket) do
    appointment = Appointments.get_appointment!(appointment_id)
    if appointment.prescription do
      user = Accounts.get_user!(appointment.user_id)

      socket =
        assign(
          socket,
          live_action: :show,
          open_prescription_modal?: true,
          page_title: "View Prescription",
          appointment: appointment,
          prescription: Prescriptions.get_prescription!(appointment.prescription.id) ,
          user: user
        )
      {:noreply, socket}
    else
      {:noreply,
        socket
        |> put_flash(:error, "Prescription Not Found")
        |> push_redirect(to: Routes.doctor_doctor_appointment_path(socket, :appointment))
      }
    end
  end
end
