defmodule Physio.Appointments.Appointment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "appointments" do
    field :date, :date
    field :description, :string
    field :time, :time

    belongs_to :doctor, Physio.Accounts.Doctor
    belongs_to :user, Physio.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(appointment, attrs) do
    appointment
    |> cast(attrs, [:description, :date, :time])
    |> validate_required([:description, :date, :time])
  end
end
