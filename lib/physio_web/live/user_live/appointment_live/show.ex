defmodule PhysioWeb.UserLive.AppointmentLive.Show do
  use PhysioWeb, :live_view

  alias Physio.Appointments

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_user: find_current_user(session))
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:appointment, Appointments.get_appointment!(id))}
  end

  defp page_title(:show), do: "Show Appointment"
  defp page_title(:edit), do: "Edit Appointment"
end
