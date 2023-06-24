defmodule PhysioWeb.AdminLive.DoctorIndex do
  use PhysioWeb, :live_view

  alias Physio.Accounts

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_admin: find_current_admin(session))
    doctors = Accounts.list_doctor()
    {:ok,
      socket
      |> assign(
        doctors: doctors
      )
    }
  end
end
