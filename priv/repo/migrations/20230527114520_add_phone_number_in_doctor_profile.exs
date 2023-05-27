defmodule Physio.Repo.Migrations.AddPhoneNumberInDoctorProfile do
  use Ecto.Migration

  def up do
    alter table(:doctor_profiles) do
      add :phone_number, :string
      add :gender, :string
      add :experience, :string
    end
  end

  def down do
    alter table(:doctor_profiles) do
      remove :phone_number
      remove :gender
      remove :experience
    end
  end
end
