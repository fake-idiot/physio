defmodule PhysioWeb.UserLive.AppointmentLive.FormComponent do
  use PhysioWeb, :live_component

  alias Physio.Accounts
  alias Physio.Appointments

  @impl true
  def update(%{appointment: appointment} = assigns, socket) do
    changeset = Appointments.change_appointment(appointment)
    doctor_option = doctor_options(assigns)
    disable = if Map.has_key?(assigns, :type), do: "pointer-events: none;"

    {:ok,
     socket
     |> assign(assigns)
     |> assign(changeset: changeset,
      doctor_option: doctor_option,
      disable: disable
     )
    }
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

  defp doctor_options(assigns) do
    if Map.has_key?(assigns, :doctor_id) do
      Accounts.list_doctor()
      |> Enum.filter(&(&1.id == String.to_integer(assigns.doctor_id)))
      |> Enum.map(fn doctor -> %{id: doctor.id, name: doctor.doctor_profile.first_name} end)
    else
      Accounts.list_doctor()
      |> Enum.map(fn doctor -> %{id: doctor.id, name: doctor.doctor_profile.first_name} end)
    end
  end
end
