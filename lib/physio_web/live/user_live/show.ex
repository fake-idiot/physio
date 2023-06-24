defmodule PhysioWeb.UserLive.Show do
  use PhysioWeb, :live_view

  alias Physio.Accounts
  alias Physio.Appointments
  alias Physio.Prescriptions

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_doctor: find_current_doctor(session))
    {:ok,
      socket
      |> assign(
        open_prescription_modal?: false
      )
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    user_appointments = Appointments.listing_appointments_by_user_id(id)
    {:noreply,
     socket
     |> assign(
      open_prescription_modal?: false,
      user: Accounts.get_user!(id),
      user_appointments: user_appointments
     )
    }
  end

  @impl true
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
        |> push_redirect(to: Routes.user_show_path(socket, :show, socket.assigns.user.id))
      }
    end
  end
end
