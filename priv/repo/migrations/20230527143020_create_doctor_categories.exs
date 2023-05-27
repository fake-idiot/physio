defmodule Physio.Repo.Migrations.CreateDoctorCategories do
  use Ecto.Migration

  def change do
    create table(:doctor_categories) do
      add :doctor_id, references(:doctors, on_delete: :delete_all)
      add :category_id, references(:categories, on_delete: :delete_all)
      add :sub_category_id, references(:sub_categories, on_delete: :delete_all)

      timestamps()
    end
  end
end
