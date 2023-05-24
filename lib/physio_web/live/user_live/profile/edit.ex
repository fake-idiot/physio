defmodule PhysioWeb.UserLive.Profile.Edit do
  use PhysioWeb, :live_view

  @impl Phoenix.LiveView
  def mount(params, session, socket) do
    {:ok, socket |> assign(current_user: find_current_user(session))}
  end
end
