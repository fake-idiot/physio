defmodule PhysioWeb.Components.UserHeader do
  use PhysioWeb, :live_component

  def render(assigns) do
    ~H"""
      <div class="flex h-16 bg-gray-900" id="header">
        <header class="w-full text-gray-100 bg-gray-900 shadow-sm body-font">
            <div class="container flex flex-col flex-wrap justify-end p-1 mx-auto md:flex-row">
                <div class="inline-flex items-center h-full ml-5 lg:w-2/5 lg:justify-end lg:ml-0">
                    <button id="myDropdown" data-dropdown-toggle="dropdown" class="mr-5 font-medium hover:text-gray-300" onclick="dropdown()">
                        <%= @current_user.user_profile.first_name %> <%= @current_user.user_profile.last_name %>
                    </button>

                    <ul aria-label="top bar left" aria-orientation="horizontal" class="flex">
                        <li class="group relative">
                            <button aria-controls="add" aria-expanded="false" aria-haspopup="listbox" class="flex items-center h-full px-4 text-sm">
                                <%= if @current_user.user_profile.profile_img do%>
                                    <img src={@current_user.user_profile.profile_img} class="h-12 w-12 shadow-xl rounded-full align-middle border-2 border-gray-700"/>
                                <% else %>
                                    <img src={Routes.static_path(@socket, "/images/default_user.png")} alt="img" class="h-12 w-12 shadow-xl rounded-full align-middle border-2 border-gray-700"/>
                                <% end %>
                            </button>
                            <span class="absolute -ml-12 hidden group-hover:block w-fit">
                                <ul id="add" role="listbox" class="outline-none py-2 bg-white text-gray-900 border rounded-md w-max-content w-dropdown-large shadow-lg focus:outline-none leading-relaxed">
                                    <li role="option" class="px-6 py-1 my-1 focus:outline-none focus:bg-blue-100 hover:bg-blue-100 cursor-pointer">
                                      <%= link "Log out", to: Routes.user_session_path(@socket, :delete), method: :delete %>
                                    </li>
                                </ul>
                            </span>
                        </li>
                    </ul>
                </div>
            </div>
        </header>
      </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("log_out", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.user_session_path(socket, :delete), method: :delete)}
  end

end
