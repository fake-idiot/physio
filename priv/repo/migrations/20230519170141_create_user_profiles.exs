defmodule Physio.Repo.Migrations.CreateUserProfiles do
  use Ecto.Migration

  def change do
    create table(:user_profiles) do
      add :first_name, :string
      add :last_name, :string
      add :profile_img, :string

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
  end
end
