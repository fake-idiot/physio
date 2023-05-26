defmodule Physio.Repo.Migrations.AddFieldsInDoctorProfile do
  use Ecto.Migration

  def up do
    alter table(:doctor_profiles) do
      add :clinic_address, :string
      add :bio, :string
      add :rating, :string
    end

    create index(:doctor_profiles, [:clinic_address, :bio, :rating])
  end

  def down do
    alter table(:doctor_profiles) do
      remove :clinic_address, :string
      remove :bio, :string
      remove :rating, :string
    end
  end
end
