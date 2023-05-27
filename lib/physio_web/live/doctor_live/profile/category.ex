defmodule PhysioWeb.DoctorLive.Profile.Category do
  use PhysioWeb, :live_component

  alias Physio.Categories

  @impl true
  def update(%{doctor_category: doctor_category} = assigns, socket) do
    category_changeset = Categories.change_doctor_category(doctor_category)
    categories = categoies_option()
    IO.inspect(categories, label: "categories")

    socket =
    socket
    |> assign(assigns)
    |> assign(
      category_changeset: category_changeset,
      doctor_id: assigns.doctor_id,
      categories: categories,
      sub_categories: sub_categoies_option(List.first(categories).id)
      )
    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"doctor_category" => doctor_category}, socket) do
    sub_categories = sub_categoies_option(String.to_integer(doctor_category["category_id"]))

    socket =
    socket
    |> assign(
      sub_categories: sub_categories
      )
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"doctor_category" => doctor_category}, socket) do
    IO.inspect(doctor_category, label: "doctor_category")
    socket =
    case Categories.create_doctor_category(doctor_category) do
      {:ok, _} ->
        socket |> put_flash(:info, "Category has been added.")
        |> redirect(to: Routes.doctor_profile_edit_path(socket, :edit))
      {:error, _} ->
        socket |> put_flash(:error, "Something went wrong.")
        |> redirect(to: Routes.doctor_profile_edit_path(socket, :edit))
    end
    {:noreply, socket}
  end

  defp sub_categoies_option(category_id) do
    Categories.list_sub_categories_by_category(category_id)
    |> Enum.map(fn sc -> %{id: sc.id, name: sc.name} end)
  end

  defp categoies_option() do
    Categories.list_categories()
    |> Enum.map(fn c -> %{id: c.id, name: c.name} end)
  end
end
