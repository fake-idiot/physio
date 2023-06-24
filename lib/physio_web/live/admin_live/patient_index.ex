defmodule PhysioWeb.AdminLive.PatientIndex do
  use PhysioWeb, :live_view

  alias Physio.Accounts

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_admin: find_current_admin(session))
    patients = Accounts.list_users()
    {:ok,
      socket
      |> assign(
        patients: patients
      )
    }
  end
end
