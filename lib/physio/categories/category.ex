defmodule Physio.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias Physio.Accounts.Doctor
  alias Physio.Categories.SubCategory
  alias Physio.Categories.DoctorCategory

  schema "categories" do
    field :name, :string

    has_many :sub_categories, SubCategory
    has_many :doctor_categories, DoctorCategory
    many_to_many :doctors, Doctor, join_through: DoctorCategory, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
