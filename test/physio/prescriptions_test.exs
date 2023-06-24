defmodule Physio.PrescriptionsTest do
  use Physio.DataCase

  alias Physio.Prescriptions

  describe "prescriptions" do
    alias Physio.Prescriptions.Prescription

    import Physio.PrescriptionsFixtures

    @invalid_attrs %{}

    test "list_prescriptions/0 returns all prescriptions" do
      prescription = prescription_fixture()
      assert Prescriptions.list_prescriptions() == [prescription]
    end

    test "get_prescription!/1 returns the prescription with given id" do
      prescription = prescription_fixture()
      assert Prescriptions.get_prescription!(prescription.id) == prescription
    end

    test "create_prescription/1 with valid data creates a prescription" do
      valid_attrs = %{}

      assert {:ok, %Prescription{} = prescription} = Prescriptions.create_prescription(valid_attrs)
    end

    test "create_prescription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Prescriptions.create_prescription(@invalid_attrs)
    end

    test "update_prescription/2 with valid data updates the prescription" do
      prescription = prescription_fixture()
      update_attrs = %{}

      assert {:ok, %Prescription{} = prescription} = Prescriptions.update_prescription(prescription, update_attrs)
    end

    test "update_prescription/2 with invalid data returns error changeset" do
      prescription = prescription_fixture()
      assert {:error, %Ecto.Changeset{}} = Prescriptions.update_prescription(prescription, @invalid_attrs)
      assert prescription == Prescriptions.get_prescription!(prescription.id)
    end

    test "delete_prescription/1 deletes the prescription" do
      prescription = prescription_fixture()
      assert {:ok, %Prescription{}} = Prescriptions.delete_prescription(prescription)
      assert_raise Ecto.NoResultsError, fn -> Prescriptions.get_prescription!(prescription.id) end
    end

    test "change_prescription/1 returns a prescription changeset" do
      prescription = prescription_fixture()
      assert %Ecto.Changeset{} = Prescriptions.change_prescription(prescription)
    end
  end

  describe "medications" do
    alias Physio.Prescriptions.Medication

    import Physio.PrescriptionsFixtures

    @invalid_attrs %{dose: nil, evening: nil, morning: nil, name: nil, night: nil}

    test "list_medications/0 returns all medications" do
      medication = medication_fixture()
      assert Prescriptions.list_medications() == [medication]
    end

    test "get_medication!/1 returns the medication with given id" do
      medication = medication_fixture()
      assert Prescriptions.get_medication!(medication.id) == medication
    end

    test "create_medication/1 with valid data creates a medication" do
      valid_attrs = %{dose: "some dose", evening: true, morning: true, name: "some name", night: true}

      assert {:ok, %Medication{} = medication} = Prescriptions.create_medication(valid_attrs)
      assert medication.dose == "some dose"
      assert medication.evening == true
      assert medication.morning == true
      assert medication.name == "some name"
      assert medication.night == true
    end

    test "create_medication/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Prescriptions.create_medication(@invalid_attrs)
    end

    test "update_medication/2 with valid data updates the medication" do
      medication = medication_fixture()
      update_attrs = %{dose: "some updated dose", evening: false, morning: false, name: "some updated name", night: false}

      assert {:ok, %Medication{} = medication} = Prescriptions.update_medication(medication, update_attrs)
      assert medication.dose == "some updated dose"
      assert medication.evening == false
      assert medication.morning == false
      assert medication.name == "some updated name"
      assert medication.night == false
    end

    test "update_medication/2 with invalid data returns error changeset" do
      medication = medication_fixture()
      assert {:error, %Ecto.Changeset{}} = Prescriptions.update_medication(medication, @invalid_attrs)
      assert medication == Prescriptions.get_medication!(medication.id)
    end

    test "delete_medication/1 deletes the medication" do
      medication = medication_fixture()
      assert {:ok, %Medication{}} = Prescriptions.delete_medication(medication)
      assert_raise Ecto.NoResultsError, fn -> Prescriptions.get_medication!(medication.id) end
    end

    test "change_medication/1 returns a medication changeset" do
      medication = medication_fixture()
      assert %Ecto.Changeset{} = Prescriptions.change_medication(medication)
    end
  end
end
