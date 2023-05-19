defmodule Physio.Repo.Migrations.CreateDoctorProfiles do
  use Ecto.Migration

  def change do
    create table(:doctor_profiles) do
      add :first_name, :string
      add :last_name, :string
      add :profile_img, :string

      add :doctor_id, references(:doctors, on_delete: :delete_all)

      timestamps()
    end
  end
end
