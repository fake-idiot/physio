defmodule Physio.Categories.SubCategory do
  use Ecto.Schema
  import Ecto.Changeset

  alias Physio.Categories.Category

  schema "sub_categories" do
    field :name, :string

    belongs_to :category, Category

    timestamps()
  end

  @doc false
  def changeset(sub_category, attrs) do
    sub_category
    |> cast(attrs, [:name, :category_id])
    |> validate_required([:name, :category_id])
  end
end
