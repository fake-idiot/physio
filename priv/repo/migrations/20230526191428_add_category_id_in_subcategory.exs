defmodule Physio.Repo.Migrations.AddCategoryIdInSubcategory do
  use Ecto.Migration

  def up do
    alter table(:sub_categories) do
      add :category_id, references(:categories, on_delete: :delete_all)
    end
  end

  def down do
    alter table(:sub_categories) do
      remove :category_id
    end
  end
end
