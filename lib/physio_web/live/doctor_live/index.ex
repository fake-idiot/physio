defmodule PhysioWeb.DoctorLive.Index do
  alias Physio.Accounts
  use PhysioWeb, :live_view

  @default_filters %{paginate: %{offset: 0, limit: 10}, search: %{"items" =>  "By Doctor", "search" => ""}}

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_user: find_current_user(session))

    {:ok, socket
      |> assign(
        doctors: Accounts.list_doctor_by_filters(@default_filters),
        filters: @default_filters
      )
    }
  end

  @impl true
  def handle_event("doc_detail", %{"doctor_id" => doctor_id}, socket) do
    socket = redirect(socket, to: Routes.doctor_show_path(socket, :show, doctor_id))
    {:noreply, socket}
  end

  def handle_event("search",  %{"search" => search}, socket) do
    search =
      if Map.has_key?(search, "search") do
        search
      else
        Map.put(search, "search", "")
      end
    filters = Map.put(socket.assigns.filters, :search, search)
    {:noreply, socket
      |> assign(
        doctors: Accounts.list_doctor_by_filters(filters),
        filters: filters
      )
    }
  end

end
