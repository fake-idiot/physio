defmodule Physio.Repo.Migrations.CreateSubCategories do
  use Ecto.Migration

  def change do
    create table(:sub_categories) do
      add :name, :string

      timestamps()
    end
  end
end
