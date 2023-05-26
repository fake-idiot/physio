defmodule PhysioWeb.Components.DoctorLeftBar do
  use PhysioWeb, :live_component

  def render(assigns) do
    ~H"""
      <div class="flex flex-col items-center justify-center bg-gray-900 min-h-screen z-10 text-slate-300 w-20 fixed left-0 h-screen overflow-y-scroll">
          <ul>
              <img class="h-10 w-10 mx-auto mb-12" src={Routes.static_path(@socket, "/images/Logo.png")} />
              <li class="h-16 px-6 flex items-center hover:text-white w-full">
                  <i class="mx-auto">
                      <svg class="fill-current h-5 w-5" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
                          <path d="M12 6.453l9 8.375v9.172h-6v-6h-6v6h-6v-9.172l9-8.375zm12 5.695l-12-11.148-12 11.133 1.361 1.465 10.639-9.868 10.639 9.883 1.361-1.465z" />
                      </svg>
                  </i>
              </li>
              <li phx-click="doctors" phx-target={@myself} class="h-16 px-6 flex items-center hover:text-white w-full">
                  <svg class="h-6 w-6" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" stroke="currentColor" viewBox="0 0 24 24">
                      <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01">
                      </path>
                  </svg>
              </li>
              <li phx-click="appointments" phx-target={@myself} class="h-16 px-6 flex items-center hover:text-white w-full">
                  <svg class="h-6 w-6" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" stroke="currentColor" viewBox="0 0 24 24">
                      <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01">
                      </path>
                  </svg>
              </li>
              <li phx-click="profile" phx-target={@myself} class="h-16 px-6 flex items-center hover:text-white w-full">
                  <svg class="h-6 w-6" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" stroke="currentColor" viewBox="0 0 24 24">
                      <path d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                  </svg>
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
    {:noreply, push_redirect(socket, to: Routes.user_dashboard_path(socket, :dashboard))}
  end

  @impl true
  def handle_event("doctors", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.doctor_index_path(socket, :index))}
  end

  @impl true
  def handle_event("appointments", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.user_appointment_index_path(socket, :index))}
  end

  @impl true
  def handle_event("profile", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.user_profile_edit_path(socket, :edit))}
  end
end
