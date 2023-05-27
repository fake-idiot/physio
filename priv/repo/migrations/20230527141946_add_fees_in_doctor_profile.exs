defmodule Physio.Repo.Migrations.AddFeesInDoctorProfile do
  use Ecto.Migration

  def up do
    alter table(:doctor_profiles) do
      add :online_fee, :integer
      add :physical_fee, :integer
    end
  end

  def down do
    alter table(:doctor_profiles) do
      remove :online_fee
      remove :physical_fee
    end
  end
end
