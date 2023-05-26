defmodule PhysioWeb.DoctorLive.Index do
  alias Physio.Accounts
  use PhysioWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_user: find_current_user(session))

    {:ok, socket |> assign(doctors: Accounts.list_doctor())}
  end

  def handle_event("doc_detail", %{"doctor_id" => doctor_id}, socket) do

    {:noreply, socket}
  end

end
