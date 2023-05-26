defmodule Physio.Accounts.UserProfile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_profiles" do
    field :first_name, :string
    field :last_name, :string
    field :profile_img, :string
    field :permanant_address, :string
    field :current_address, :string
    field :phone_number, :string
    field :gender, :string
    field :dob, :date

    belongs_to :user, Physio.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(user_profile, attrs) do
    user_profile
    |> cast(attrs, [:first_name, :last_name, :profile_img, :permanant_address, :current_address, :phone_number, :gender, :dob])
    |> validate_format(:phone_number, ~r/^(\+\d{1,3}\s?)?(\()?\d{3}(\))?[-.\s]?\d{3}[-.\s]?\d{4}$/, message: "Enter a valid Phone number")
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
