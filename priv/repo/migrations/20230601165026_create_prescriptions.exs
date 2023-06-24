defmodule Physio.Repo.Migrations.CreatePrescriptions do
  use Ecto.Migration

  def change do
    create table(:prescriptions) do
      add :user_id, references(:users)
      add :doctor_id, references(:doctors)
      add :appointment_id, references(:appointments)
      timestamps()
    end
  end
end
