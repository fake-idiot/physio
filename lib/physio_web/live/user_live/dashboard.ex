defmodule PhysioWeb.UserLive.Dashboard do
  use PhysioWeb, :live_view

  alias Physio.Accounts

  def mount(_params, session, socket) do

    {:ok, socket |> assign(current_user: find_current_user(session))}
  end

end
