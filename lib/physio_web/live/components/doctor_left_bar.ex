defmodule PhysioWeb.Components.DoctorLeftBar do
  use PhysioWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
      <div class="flex flex-col items-center justify-center bg-gray-900 min-h-screen z-10 text-slate-300 w-20 fixed left-0 h-screen overflow-y-scroll">
          <ul>
              <img class="h-10 w-10 mx-auto mb-12" src={Routes.static_path(@socket, "/images/Logo.png")} />
              <li phx-click="dashboard" phx-target={@myself} class="h-16 px-6 flex items-center hover:text-white w-full">
                  <img class="h-6 w-6" src={Routes.static_path(@socket, "/images/dashboard_icon.png")} />
              </li>
              <li phx-click="patients" phx-target={@myself} class="h-16 px-6 flex items-center hover:text-white w-full">
                  <img class="h-6 w-6 " src={Routes.static_path(@socket, "/images/patient_icon.png")} />
              </li>
              <li phx-click="appointments" phx-target={@myself} class="h-16 px-6 flex items-center hover:text-white w-full">
                  <img class="h-6 w-6 " src={Routes.static_path(@socket, "/images/appointment_icon.png")} />
              </li>
              <li phx-click="profile" phx-target={@myself} class="h-16 px-6 flex items-center hover:text-white w-full">
                  <img class="h-6 w-6 " src={Routes.static_path(@socket, "/images/profile_icon.png")} />
              </li>
          </ul>
      </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("dashboard", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.doctor_dashboard_path(socket, :dashboard))}
  end

  @impl true
  def handle_event("patients", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.user_index_path(socket, :index))}
  end

  @impl true
  def handle_event("appointments", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.doctor_doctor_appointment_path(socket, :appointment))}
  end

  @impl true
  def handle_event("profile", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.doctor_profile_edit_path(socket, :edit))}
  end
end
