defmodule Physio.Repo.Migrations.CreateAppointments do
  use Ecto.Migration

  def change do
    create table(:appointments) do
      add :description, :string
      add :date, :date
      add :time, :time

      add :user_id, references(:users, on_delete: :delete_all)
      add :doctor_id, references(:doctors, on_delete: :delete_all)

      timestamps()
    end
  end
end
