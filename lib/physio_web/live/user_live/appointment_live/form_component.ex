defmodule PhysioWeb.UserLive.AppointmentLive.FormComponent do
  use PhysioWeb, :live_component

  alias Physio.Accounts
  alias Physio.Appointments

  @time_list [
    "08:00",
    "08:30",
    "09:00",
    "09:30",
    "10:00",
    "10:30",
    "11:00",
    "11:30",
    "12:00",
    "12:30",
    "13:00",
    "13:30",
    "14:00",
    "14:30",
    "15:00",
    "15:30",
    "16:00",
    "16:30",
    "17:00",
    "17:30",
  ]

  @impl true
  def update(%{appointment: appointment} = assigns, socket) do
    changeset = Appointments.change_appointment(appointment)
    doctor_option = doctor_options(assigns)
    disable = if Map.has_key?(assigns, :type), do: "pointer-events: none;"
    show_modal = if (assigns.action == :show), do: "pointer-events: none;"

    {:ok,
     socket
     |> assign(assigns)
     |> assign(changeset: changeset,
      doctor_option: doctor_option,
      disable: disable,
      already_taken: false,
      time_list: @time_list,
      show: show_modal,
      open_prescriptioin_modal: false
     )
    }
  end

  @impl true
  def handle_event("validate", %{"appointment" => appointment_params}, socket) do
    {:ok, input_time} = Time.from_iso8601("#{appointment_params["time"]}:00")
    doctor_appointments = Appointments.available_appointments_by_doctor_id(appointment_params["doctor_id"], appointment_params["date"], input_time)

    if !Enum.empty?(doctor_appointments) do
        changeset =
          socket.assigns.appointment
          |> Appointments.change_appointment(appointment_params)
          |> Map.put(:action, :validate)
      {:noreply, assign(socket, changeset: changeset, already_taken: "Time slot already has been taken. Please find another one")}
    else
      changeset =
        socket.assigns.appointment
        |> Appointments.change_appointment(appointment_params)
        |> Map.put(:action, :validate)

      {:noreply, assign(socket, changeset: changeset, already_taken: false)}
    end
  end

  def handle_event("save", %{"appointment" => appointment_params}, socket) do
    if socket.assigns.already_taken do
      {:noreply, assign(socket, changeset: socket.assigns.changeset, already_taken: socket.assigns.already_taken)}
    else
      save_appointment(socket, socket.assigns.action, appointment_params)
    end
  end

  @impl true
  def handle_event("prescriiption", _, socket) do
    socket =
      assign(
        socket,
        open_prescriptioin_modal: true
      )
    {:noreply, socket}
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

  def check_appointment_date(appointments, input_date) do
    {:ok, input_date} = Date.from_iso8601(input_date)

    Enum.any?(appointments, fn appointment ->
      appointment.date == input_date
    end)
  end

  def check_appointment_time(appointments, input_time) do
    {:ok, input_time} = Time.from_iso8601("#{input_time}:00")

    Enum.any?(appointments, fn appointment ->
      appointment.time == input_time
    end)
  end
end
