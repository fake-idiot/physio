defmodule PhysioWeb.DoctorLive.Profile.Edit do
  use PhysioWeb, :live_view

  alias Physio.Accounts

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    socket = socket |> assign(current_doctor: find_current_doctor(session))

    doctor = socket.assigns.current_doctor

    changeset = Accounts.doctor_changeset(doctor)

    {:ok, socket
          |> assign(
            changeset: changeset
          )
          |> allow_upload(
            :photos,
            accept: ~w(.png .jpeg),
            max_entries: 1,
            max_file_size: 10_000_000
          )
          |> allow_upload(
            :images,
            accept: ~w(.png .jpeg),
            max_entries: 3,
            max_file_size: 10_000_000
          )
    }
  end

  @impl true
  def handle_event("validate",  %{"doctor" => doctor_params}, socket) do
    changeset =
      socket.assigns.current_doctor
      |> Accounts.doctor_changeset(doctor_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  @impl true
  def handle_event("update", %{"doctor" => doctor_params}, socket) do
    doctor_params =
      if !is_nil(List.first(upload_photos(socket, :photos))) do
        Map.put(doctor_params, "doctor_profile", Map.put(doctor_params["doctor_profile"], "profile_img", List.first(upload_photos(socket, :photos))))
      else
        doctor_params
      end

    doctor_params =
      if !is_nil(upload_photos(socket, :images)) do
        Map.put(doctor_params, "doctor_profile", Map.put(doctor_params["doctor_profile"], "degrees", upload_photos(socket, :images)))
      else
        doctor_params
      end

    socket =
      if socket.assigns.changeset.valid? do
        case Accounts.update_doctor_with_doctor_profile(socket.assigns.current_doctor, doctor_params) do
          {:ok, _} ->
            socket
            |> put_flash(:info, "Profile has been updated")
            |> redirect(to: Routes.doctor_profile_edit_path(socket, :edit))
          {:error, _} ->
            socket
            |> put_flash(:info, "Somthing went wrong")
            |> redirect(to: Routes.doctor_profile_edit_path(socket, :edit))
        end
      end
    {:noreply, socket}
  end
end
