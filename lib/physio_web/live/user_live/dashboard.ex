defmodule PhysioWeb.UserLive.Dashboard do
  use PhysioWeb, :live_view

  alias Physio.Accounts

  def mount(params, session, socket) do

    IO.inspect(session, label: "session")

    socket =
    socket
    |> assign(current_user: find_current_user(session))
    {:ok, socket}
  end

end
