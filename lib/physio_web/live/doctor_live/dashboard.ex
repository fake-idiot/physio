defmodule PhysioWeb.DoctorLive.Dashboard do
  use PhysioWeb, :live_view

  alias Physio.Accounts
  alias Physio.Appointments
  alias Physio.Prescriptions

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_doctor: find_current_doctor(session))
    upcoming_appointments = Appointments.upcoming_appointments_by_doctor_id(socket.assigns.current_doctor.id)
    upcoming_patients = Appointments.get_upcoming_user_appointment_by_doctor_id(socket.assigns.current_doctor.id)
    today_appointment = Appointments.get_today_appointments_by_doctor_id(socket.assigns.current_doctor.id)
    appointments = Appointments.list_appointments_by_doctor_id(socket.assigns.current_doctor.id)
    patients = Appointments.get_patients_by_doctor_id(socket.assigns.current_doctor.id)
    new_patients = Appointments.get_new_patients_by_doctor_id(socket.assigns.current_doctor.id)
    prescriptions = Prescriptions.get_prescriptions_by_doctor_id(socket.assigns.current_doctor.id)
    {:ok,
      socket
        |> assign(
          patients: patients,
          new_patients: new_patients,
          appointments: appointments,
          today_appointment: today_appointment,
          upcoming_appointments: upcoming_appointments,
          upcoming_patients: upcoming_patients,
          prescriptions: prescriptions,
          open_prescription_modal?: false
        )
    }
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
  def handle_event("view_prescription", %{"prescription_id" => prescription_id}, socket) do
    prescription = Prescriptions.get_prescription!(prescription_id)
    if prescription do
      user = Accounts.get_user!(prescription.user_id)
      appointment = Appointments.get_appointment!(prescription.appointment_id)

      socket =
        assign(
          socket,
          live_action: :show,
          open_prescription_modal?: true,
          page_title: "View Prescription",
          appointment: appointment,
          prescription: Prescriptions.get_prescription!(prescription_id) ,
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
