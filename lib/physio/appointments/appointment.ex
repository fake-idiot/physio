defmodule Physio.Appointments.Appointment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "appointments" do
    field :date, :date
    field :description, :string
    field :time, :time
    field :type, :string

    has_one :prescription, Physio.Prescriptions.Prescription
    belongs_to :doctor, Physio.Accounts.Doctor
    belongs_to :user, Physio.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(appointment, attrs) do
    appointment
    |> cast(attrs, [:description, :date, :time, :type, :doctor_id, :user_id])
    |> validate_required([:description, :date, :time, :type, :doctor_id, :user_id])
    |> validate_date_time()
  end

  defp validate_date_time(changeset) do
    date = get_change(changeset, :date) || get_field(changeset, :date) || Date.utc_today()

    time =
      get_change(changeset, :time) || get_field(changeset, :time) ||
        Time.add(Time.utc_now(), 305, :second)

    date_comparison = Date.compare(date, Date.utc_today())
    time_comparison = Time.compare(time, Time.add(Time.utc_now(), 300, :second))

    validate_date_time(changeset, date_comparison, time_comparison)
  end

  defp validate_date_time(changeset, :lt, _tm),
    do: add_error(changeset, :date, "date can't be in past")

  defp validate_date_time(changeset, :eq, :lt),
    do: add_error(changeset, :time, "time can't be in past")

  defp validate_date_time(changeset, _dt, _tm), do: changeset
end
