defmodule Physio.Repo.Migrations.AddDegreesFieldInDoctorProfile do
  use Ecto.Migration

  def up do
    alter table(:doctor_profiles) do
      add :degrees, {:array, :string}
    end

    create index(:doctor_profiles, [:degrees])
  end

  def down do
    alter table(:doctor_profiles) do
      remove :degrees, {:array, :string}
    end
  end
end
