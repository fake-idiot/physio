defmodule Physio.Repo.Migrations.AddNewFieldInUserProfile do
  use Ecto.Migration

  def up do
    alter table(:user_profiles) do
      add :permanant_address, :string
      add :current_address, :string
      add :phone_number, :string
      add :gender, :string
      add :dob, :date
    end
  end

  def down do
    alter table(:user_profiles) do
      remove :permanant_address, :string
      remove :current_address, :string
      remove :phone_number, :string
      remove :gender, :string
      remove :dob, :date
    end
  end
end
