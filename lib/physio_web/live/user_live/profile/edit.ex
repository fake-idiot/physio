defmodule PhysioWeb.UserLive.Profile.Edit do
  use PhysioWeb, :live_view

  alias Physio.Accounts

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    socket = socket |> assign(current_user: find_current_user(session))

    user = socket.assigns.current_user
    IO.inspect(user.user_profile.profile_img, label: "user.user_profile.dob")
    date = if user.user_profile.dob, do: user.user_profile.dob, else: Date.utc_today()

    changeset = Accounts.user_changeset(user)

    {:ok, socket
          |> assign(
            changeset: changeset,
            date: date
          )
          |> allow_upload(
            :photos,
            accept: ~w(.png .jpeg),
            max_entries: 1,
            max_file_size: 10_000_000
          )
    }
  end

  @impl true
  def handle_event("validate",  %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.current_user
      |> Accounts.user_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  @impl true
  def handle_event("update", %{"user" => user_params}, socket) do
    user_params = Map.put(user_params, "user_profile", Map.put(user_params["user_profile"], "profile_img", List.first(upload_photos(socket, :photos))))
    IO.inspect(user_params, label: "user_params")
    socket =
    if socket.assigns.changeset.valid? do
      case Accounts.update_user_with_user_profile(socket.assigns.current_user, user_params) do
        {:ok, _} ->
          socket
          |> put_flash(:info, "Profile has been updated")
          |> redirect(to: Routes.user_profile_edit_path(socket, :edit))
        {:error, _} ->
          socket
          |> put_flash(:info, "Somthing went wrong")
          |> redirect(to: Routes.user_profile_edit_path(socket, :edit))
      end

    end
    {:noreply, socket}
  end
end
