defmodule Physio.Accounts.DoctorProfile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "doctor_profiles" do
    field :first_name, :string
    field :last_name, :string
    field :profile_img, :string
    field :clinic_address, :string
    field :bio, :string
    field :rating, :string

    belongs_to :doctor, Physio.Accounts.Doctor

    timestamps()
  end

  @doc false
  def changeset(doctor_profile, attrs) do
    doctor_profile
    |> cast(attrs, [:first_name, :last_name, :profile_img, :clinic_address, :bio, :rating])
    |> validate_required([:first_name, :last_name])
  end
end
