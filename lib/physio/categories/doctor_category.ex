defmodule Physio.Categories.DoctorCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "doctor_categories" do
    belongs_to :doctor, Physio.Accounts.Doctor
    belongs_to :category, Physio.Categories.Category
    belongs_to :sub_category, Physio.Categories.SubCategory


    timestamps()
  end

  @doc false
  def changeset(doctor_category, attrs) do
    doctor_category
    |> cast(attrs, [:doctor_id, :category_id, :sub_category_id])
    |> validate_required([])
  end
end
