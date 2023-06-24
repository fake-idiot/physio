defmodule Physio.Repo.Migrations.CreateMedications do
  use Ecto.Migration

  def change do
    create table(:medications) do
      add :name, :string
      add :dose, :string
      add :morning, :boolean, default: false, null: false
      add :evening, :boolean, default: false, null: false
      add :night, :boolean, default: false, null: false

      add :prescription_id, references(:prescriptions)

      timestamps()
    end
  end
end
