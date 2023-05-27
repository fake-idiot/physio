defmodule Physio.Appointments do
  @moduledoc """
  The Appointments context.
  """

  import Ecto.Query, warn: false
  alias Physio.Repo

  alias Physio.Appointments.Appointment

  @doc """
  Returns the list of appointments.

  ## Examples

      iex> list_appointments()
      [%Appointment{}, ...]

  """
  def list_appointments do
    Appointment
    |> preload([doctor: [:doctor_profile], user: [:user_profile]])
    |> Repo.all()
  end

  def list_appointments_by_user_id(user_id) do
    (from app in Appointment,
      where: app.user_id == ^user_id
    )
    |> preload([doctor: [:doctor_profile], user: [:user_profile]])
    |> Repo.all()
  end

  def upcoming_appointments_by_doctor_id(doctor_id) do
    (from a in Appointment,
      where: a.doctor_id == ^doctor_id,
      where: a.date > ^Date.utc_today() or (a.date == ^Date.utc_today() and a.time > ^Time.utc_now()),
      order_by: [asc: a.date, asc: a.time],
      select: a
    )
    |> preload([doctor: [:doctor_profile], user: [:user_profile]])
    |> Repo.all()
  end

  def outdated_appointments_by_doctor_id(doctor_id) do
    (from a in Appointment,
      where: a.doctor_id == ^doctor_id,
      where: a.date < ^Date.utc_today() or (a.date == ^Date.utc_today() and a.time < ^Time.utc_now()),
      order_by: [asc: a.date, asc: a.time],
      select: a
    )
    |> preload([doctor: [:doctor_profile], user: [:user_profile]])
    |> Repo.all()
  end
  @doc """
  Gets a single appointment.

  Raises `Ecto.NoResultsError` if the Appointment does not exist.

  ## Examples

      iex> get_appointment!(123)
      %Appointment{}

      iex> get_appointment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_appointment!(id), do: Repo.get!(Appointment, id)

  @doc """
  Creates a appointment.

  ## Examples

      iex> create_appointment(%{field: value})
      {:ok, %Appointment{}}

      iex> create_appointment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_appointment(attrs \\ %{}) do
    %Appointment{}
    |> Appointment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a appointment.

  ## Examples

      iex> update_appointment(appointment, %{field: new_value})
      {:ok, %Appointment{}}

      iex> update_appointment(appointment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_appointment(%Appointment{} = appointment, attrs) do
    appointment
    |> Appointment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a appointment.

  ## Examples

      iex> delete_appointment(appointment)
      {:ok, %Appointment{}}

      iex> delete_appointment(appointment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_appointment(%Appointment{} = appointment) do
    Repo.delete(appointment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking appointment changes.

  ## Examples

      iex> change_appointment(appointment)
      %Ecto.Changeset{data: %Appointment{}}

  """
  def change_appointment(%Appointment{} = appointment, attrs \\ %{}) do
    Appointment.changeset(appointment, attrs)
  end
end
