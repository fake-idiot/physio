defmodule PhysioWeb.DoctorLive.AppointmentLive.FormComponent do
  use PhysioWeb, :live_component

  alias Physio.Appointments
  # alias Physio.Doctors

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
  def update(%{appointment: appointment} = assigns, socket) do
    changeset = Appointments.change_appointment(appointment)
    show_modal = if (assigns.action == :show), do: "pointer-events: none;"
    socket =
      assign(socket, assigns)
      |> assign(
        changeset: changeset,
        show: show_modal,
        time_list: @time_list
      )
    {:ok, socket}
  end

  def handle_event("add_prescription", _payload, socket) do
    {:noreply, socket}
  end
end
