defmodule Physio.Repo.Migrations.CreateDoctorsAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:doctors) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:doctors, [:email])

    create table(:doctors_tokens) do
      add :doctor_id, references(:doctors, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:doctors_tokens, [:doctor_id])
    create unique_index(:doctors_tokens, [:context, :token])
  end
end
