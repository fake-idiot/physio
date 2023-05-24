defmodule PhysioWeb.UserLive.Profile.Index do
  use PhysioWeb, :live_view

  @impl true
  def mount(_params, session, socket) do

    {:ok, socket |> assign(current_user: find_current_user(session))}
  end
end
