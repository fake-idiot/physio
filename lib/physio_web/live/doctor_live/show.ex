defmodule PhysioWeb.DoctorLive.Show do
  alias Physio.Accounts
  use PhysioWeb, :live_view
  alias Physio.Appointments.Appointment
  alias Physio.Categories

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(current_user: find_current_user(session))
    {:ok, socket
          |> assign(
            appointment_modal?: false
            )
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    doctor_categories = Categories.get_categories_by_doctor_id(id)
    {:noreply,
     socket
     |> assign(
      appointment_modal?: false,
      doctor: Accounts.get_doctor!(id),
      doctor_id: id,
      doctor_categories: doctor_categories
     )
    }
  end

  @impl true
  def handle_event("physical_appointment", _payload, socket) do
    {:noreply,
      socket
      |> assign(appointment_modal?: true,
      appointment: %Appointment{},
      live_action: :new,
      page_title: "Add New Appointment",
      type: ["Physical": "Physical"]
      )
    }
  end

  def handle_event("online_appointment", _payload, socket) do
    {:noreply,
      socket
      |> assign(appointment_modal?: true,
      appointment: %Appointment{},
      live_action: :new,
      page_title: "Add New Appointment",
      type: ["Online": "Online"]
      )
    }
  end

end
