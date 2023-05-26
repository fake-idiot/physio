defmodule PhysioWeb.DoctorLive.Dashboard do
  use PhysioWeb, :live_view

  def mount(_params, session, socket) do
    socket = socket |> assign(current_doctor: find_current_doctor(session))
    {:ok, socket}
  end

end
