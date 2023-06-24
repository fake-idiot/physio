defmodule Physio.Prescriptions.Medication do
  use Ecto.Schema
  import Ecto.Changeset

  alias Physio.Prescriptions.Prescription

  schema "medications" do
    field :dose, :string
    field :evening, :boolean, default: false
    field :morning, :boolean, default: false
    field :name, :string
    field :night, :boolean, default: false

    belongs_to :prescription, Prescription

    timestamps()
  end

  @doc false
  def changeset(medication, attrs) do
    medication
    |> cast(attrs, [:name, :dose, :morning, :evening, :night])
    |> validate_required([:name, :dose, :morning, :evening, :night])
  end
end
