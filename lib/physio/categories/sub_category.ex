defmodule Physio.Categories.SubCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sub_categories" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(sub_category, attrs) do
    sub_category
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
