defmodule PhysioWeb.Components.LeftBar do
  use PhysioWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("dashboard", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.user_dashboard_path(socket, :dashboard))}
  end

  @impl true
  def handle_event("profile", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.user_profile_edit_path(socket, :edit))}
  end
end
