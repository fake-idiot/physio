defmodule PhysioWeb.Components.Footer do
  use PhysioWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="fixed bottom-0 w-full">
      <footer aria-label="Site Footer" class="bg-gray-50">
        <div class="mx-auto max-w-screen-xl px-4">
          <div class="sm:flex sm:items-center sm:justify-between">
            <div class="flex justify-center items-center text-teal-600 sm:justify-start">
              <img src={Routes.static_path(@socket, "/images/Logo.png")} class="h-14 w-14" />
              <p class="text-lg font-semibold italic">Physio</p>
            </div>

            <p class="mt-4 text-center text-sm text-gray-500 lg:mt-0 lg:text-right">
              Copyright &copy; 2023. All rights reserved.
            </p>
          </div>
        </div>
      </footer>
    </div>
    """
  end

  def update(_assigns, socket) do
    {:ok, socket}
  end
end
