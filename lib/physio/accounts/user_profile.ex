defmodule Physio.Accounts.UserProfile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_profiles" do
    field :first_name, :string
    field :last_name, :string
    field :profile_img, :string

    belongs_to :user, Physio.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(user_profile, attrs) do
    user_profile
    |> cast(attrs, [:first_name, :last_name, :profile_img])
  end

  defp validate_name(changeset) do
    changeset
    |> validate_required([:first_name, :last_name])
    |> validate_format([:first_name, :last_name], ~r/^[a-zA-Z]+(?:['\s-][a-zA-Z]+)*$/, message: "Enter valid name")
    |> validate_length([:first_name, :last_name], max: 20)
  end
end
