defmodule Physio.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias Physio.Categories.SubCategory

  schema "categories" do
    field :name, :string

    has_many :sub_categories, SubCategory

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
