defmodule PhysioWeb.DoctorRegistrationController do
  use PhysioWeb, :controller

  alias Physio.Accounts
  alias Physio.Accounts.Doctor
  alias PhysioWeb.DoctorAuth

  def new(conn, _params) do
    changeset = Accounts.change_doctor_registration(%Doctor{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"doctor" => doctor_params}) do
    case Accounts.register_doctor(doctor_params) do
      {:ok, doctor} ->
        {:ok, _} =
          Accounts.deliver_doctor_confirmation_instructions(
            doctor,
            &Routes.doctor_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "Doctor created successfully.")
        |> redirect(to: Routes.doctor_session_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
