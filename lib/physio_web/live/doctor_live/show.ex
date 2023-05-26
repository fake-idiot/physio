defmodule PhysioWeb.DoctorLive.Show do
  use PhysioWeb, :live_view

  def mount(_params, session, socket) do
    socket = socket |> assign(current_user: find_current_user(session))
    {:ok, socket}
  end

end
