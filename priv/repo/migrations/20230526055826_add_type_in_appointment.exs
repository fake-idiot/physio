defmodule Physio.Repo.Migrations.AddTypeInAppointment do
  use Ecto.Migration

  def up do
    alter table(:appointments) do
      add :type, :string
    end

    create index(:appointments, [:type])
  end

  def down do
    alter table(:appointments) do
      remove :type, :string
    end
  end
end
