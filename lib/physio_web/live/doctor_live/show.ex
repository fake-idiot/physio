defmodule PhysioWeb.DoctorLive.Show do
  alias Physio.Accounts
  use PhysioWeb, :live_view
  alias Physio.Appointments.Appointment

  def mount(_params, session, socket) do
    socket = socket |> assign(current_user: find_current_user(session))
    {:ok, socket |> assign(appointment_modal?: false)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(doctor: Accounts.get_doctor!(id),
     doctor_id: id
     )
     |> assign(appointment_modal?: false)
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
