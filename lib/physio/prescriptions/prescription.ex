defmodule Physio.Prescriptions.Prescription do
  use Ecto.Schema
  import Ecto.Changeset

  alias Physio.Accounts.User
  alias Physio.Accounts.Doctor
  alias Physio.Appointments.Appointment
  alias Physio.Prescriptions.Medication

  schema "prescriptions" do
    has_many :medications, Medication, on_replace: :delete
    belongs_to :appointment, Appointment
    belongs_to :user, User
    belongs_to :doctor, Doctor

    timestamps()
  end

  @doc false
  def changeset(prescription, attrs) do
    prescription
    |> cast(attrs, [:appointment_id, :user_id, :doctor_id])
    |> cast_assoc(:medications, with: &Medication.changeset/2, required: true)
    |> validate_required([])
  end
end
