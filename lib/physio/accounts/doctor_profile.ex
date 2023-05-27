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
    field :degrees, {:array, :string}
    field :phone_number, :string
    field :gender, :string
    field :experience, :string

    belongs_to :doctor, Physio.Accounts.Doctor

    timestamps()
  end

  @doc false
  def changeset(doctor_profile, attrs) do
    doctor_profile
    |> cast(attrs, [:first_name, :last_name, :profile_img, :clinic_address, :bio, :rating, :degrees, :experience, :gender, :phone_number])
    |> validate_format(:phone_number, ~r/^(\+\d{1,3}\s?)?(\()?\d{3}(\))?[-.\s]?\d{3}[-.\s]?\d{4}$/, message: "Enter a valid Phone number")
    |> validate_length(:bio, max: 250)
    |> validate_name()
  end

  defp validate_name(changeset) do
    changeset
    |> validate_required([:first_name, :last_name])
    |> validate_format(:first_name, ~r/^[a-zA-Z]+(?:['\s-][a-zA-Z]+)*$/, message: "Enter a valid name")
    |> validate_format(:last_name, ~r/^[a-zA-Z]+(?:['\s-][a-zA-Z]+)*$/, message: "Enter a valid name")
    |> validate_length(:first_name, max: 20)
    |> validate_length(:last_name, max: 20)
  end
end
