defmodule Physio.PrescriptionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Physio.Prescriptions` context.
  """

  @doc """
  Generate a prescription.
  """
  def prescription_fixture(attrs \\ %{}) do
    {:ok, prescription} =
      attrs
      |> Enum.into(%{

      })
      |> Physio.Prescriptions.create_prescription()

    prescription
  end

  @doc """
  Generate a medication.
  """
  def medication_fixture(attrs \\ %{}) do
    {:ok, medication} =
      attrs
      |> Enum.into(%{
        dose: "some dose",
        evening: true,
        morning: true,
        name: "some name",
        night: true
      })
      |> Physio.Prescriptions.create_medication()

    medication
  end
end
