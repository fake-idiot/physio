defmodule PhysioWeb.AppointmentLive.FormComponent do
  use PhysioWeb, :live_component

  alias Physio.Appointments

  @impl true
  def update(%{appointment: appointment} = assigns, socket) do
    changeset = Appointments.change_appointment(appointment)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"appointment" => appointment_params}, socket) do
    changeset =
      socket.assigns.appointment
      |> Appointments.change_appointment(appointment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"appointment" => appointment_params}, socket) do
    save_appointment(socket, socket.assigns.action, appointment_params)
  end

  defp save_appointment(socket, :edit, appointment_params) do
    case Appointments.update_appointment(socket.assigns.appointment, appointment_params) do
      {:ok, _appointment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Appointment updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_appointment(socket, :new, appointment_params) do
    case Appointments.create_appointment(appointment_params) do
      {:ok, _appointment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Appointment created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
