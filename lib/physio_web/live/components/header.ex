defmodule PhysioWeb.Components.Header do
  use PhysioWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("log_out", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.user_session_path(socket, :delete), method: :delete)}
  end

end
