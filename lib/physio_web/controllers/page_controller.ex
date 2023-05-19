defmodule PhysioWeb.PageController do
  use PhysioWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
