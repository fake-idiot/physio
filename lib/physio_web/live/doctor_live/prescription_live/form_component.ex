defmodule PhysioWeb.DoctorLive.PrescriptionLive.FormComponent do
  use PhysioWeb, :live_component

  import Ecto.Changeset

  alias Physio.Prescriptions
  alias Physio.Prescriptions.Medication

  @default_medication_params %{name: "", dose: "", morning: false, evening: false, night: false}
  @default_params %{medications: [@default_medication_params]}

  @impl true
  def update(%{prescription: prescription} = assigns, socket) do
    {prescription, default_params} = get_prescription_with_params(prescription, assigns.action)
    changeset = Prescriptions.change_prescription(prescription, default_params)
    socket =
      assign(socket, assigns)
      |> assign(
        changeset: changeset
      )
    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"prescription" => prescription_params}, socket) do
    changeset =
    socket.assigns.prescription
    |> Prescriptions.change_prescription(prescription_params)
    |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("add_more_prescription", %{"index" => index}, socket) do
    changeset = socket.assigns.changeset

    addtional_emails =
      remove_field(
        changeset.changes.medications |> Enum.reject(&(&1.action == :replace)),
        index
      )

    changeset = put_in(changeset.changes.medications, addtional_emails)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("add_more_prescription", _, socket) do
    changeset = socket.assigns.changeset
    medication_changeset = change(%Medication{}, @default_medication_params)

    medications = changeset.changes.medications ++ [medication_changeset]
    changeset = put_in(changeset.changes.medications, medications)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"prescription" => prescription_params}, socket) do
    if socket.assigns.changeset.valid? do
      case Prescriptions.create_prescription(prescription_params) do
        {:ok, _prescription} ->
          {:noreply,
            socket
            |> put_flash(:info, "Prescription has been added Successfully")
            |> push_redirect(to: Routes.doctor_doctor_appointment_path(socket, :appointment))
          }

        {:error, _prescription} ->
          {:noreply,
            socket
            |> put_flash(:error, "Something went wrong")
            |> push_redirect(to: Routes.doctor_doctor_appointment_path(socket, :appointment))
          }
      end
    else
      {:noreply, assign(socket, :changeset, socket.assigns.changeset)}
    end
  end

  defp remove_field(changeset_list, index) do
    changeset_list
    |> Enum.with_index()
    |> Enum.reduce([], fn {value, i}, acc -> if "#{i}" == index, do: acc, else: acc ++ [value] end)
  end

  defp get_prescription_with_params(prescription, :new),
    do: {prescription, @default_params}

  defp get_prescription_with_params(prescription, :show) do
    medications =
      Enum.map(prescription.medications, fn medication ->
        medication
        |> Map.from_struct()
        |> Map.drop([:__meta__, :prescription])
      end)

    prescription =
      prescription
      |> Map.put(:medications, [])

    {prescription,
     %{
       medications: medications
     }}
  end

  defp get_prescription_with_params(prescription, :show_pres) do
    medications =
      Enum.map(prescription.medications, fn medication ->
        medication
        |> Map.from_struct()
        |> Map.drop([:__meta__, :prescription])
      end)

    prescription =
      prescription
      |> Map.put(:medications, [])

    {prescription,
     %{
       medications: medications
     }}
  end
end
