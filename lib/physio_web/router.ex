defmodule PhysioWeb.Router do
  use PhysioWeb, :router

  import PhysioWeb.AdminAuth

  import PhysioWeb.DoctorAuth

  import PhysioWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PhysioWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_admin
    plug :fetch_current_doctor
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhysioWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhysioWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PhysioWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", PhysioWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", PhysioWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    live "/user_dashboard", UserLive.Dashboard, :dashboard
    live "/user_profile", UserLive.Profile.Index, :index
    live "/edit_profile", UserLive.Profile.Edit, :edit
    live "/user_appointments", UserLive.AppointmentLive.Index, :index
    live "/user_appointments/new", UserLive.AppointmentLive.Index, :new
    live "/user_appointments/:id/show", UserLive.AppointmentLive.Show, :show
    live "/doctors", DoctorLive.Index, :index
    live "/doctors/:id/show", DoctorLive.Show, :show
  end

  scope "/", PhysioWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end

  ## Authentication routes

  scope "/", PhysioWeb do
    pipe_through [:browser, :redirect_if_doctor_is_authenticated]

    get "/doctors/register", DoctorRegistrationController, :new
    post "/doctors/register", DoctorRegistrationController, :create
    get "/doctors/log_in", DoctorSessionController, :new
    post "/doctors/log_in", DoctorSessionController, :create
    get "/doctors/reset_password", DoctorResetPasswordController, :new
    post "/doctors/reset_password", DoctorResetPasswordController, :create
    get "/doctors/reset_password/:token", DoctorResetPasswordController, :edit
    put "/doctors/reset_password/:token", DoctorResetPasswordController, :update
  end

  scope "/", PhysioWeb do
    pipe_through [:browser, :require_authenticated_doctor]

    get "/doctors/settings", DoctorSettingsController, :edit
    put "/doctors/settings", DoctorSettingsController, :update
    get "/doctors/settings/confirm_email/:token", DoctorSettingsController, :confirm_email

    # live "/doctor_profile",DoctorLive.Profile.Index, :index
    live "/edit_doctor_profile", DoctorLive.Profile.Edit, :edit

    live "/doctor_dashboard", DoctorLive.Dashboard, :dashboard
    live "/doctor_appointments", DoctorLive.DoctorAppointment, :appointment
    live "/patients", UserLive.Index, :index
    live "/pateint/:id/show", UserLive.Show, :show
  end

  scope "/", PhysioWeb do
    pipe_through [:browser]

    delete "/doctors/log_out", DoctorSessionController, :delete
    get "/doctors/confirm", DoctorConfirmationController, :new
    post "/doctors/confirm", DoctorConfirmationController, :create
    get "/doctors/confirm/:token", DoctorConfirmationController, :edit
    post "/doctors/confirm/:token", DoctorConfirmationController, :update
  end

  ## Authentication routes

  scope "/", PhysioWeb do
    pipe_through [:browser, :redirect_if_admin_is_authenticated]

    get "/admins/register", AdminRegistrationController, :new
    post "/admins/register", AdminRegistrationController, :create
    get "/admins/log_in", AdminSessionController, :new
    post "/admins/log_in", AdminSessionController, :create
    get "/admins/reset_password", AdminResetPasswordController, :new
    post "/admins/reset_password", AdminResetPasswordController, :create
    get "/admins/reset_password/:token", AdminResetPasswordController, :edit
    put "/admins/reset_password/:token", AdminResetPasswordController, :update
  end

  scope "/", PhysioWeb do
    pipe_through [:browser, :require_authenticated_admin]

    get "/admins/settings", AdminSettingsController, :edit
    put "/admins/settings", AdminSettingsController, :update
    get "/admins/settings/confirm_email/:token", AdminSettingsController, :confirm_email

    live "/admin_dashbord", AdminLive.Dashboard, :dashboard
    live "/client_patients", AdminLive.PatientIndex, :index
    live "/client_docctors", AdminLive.DoctorIndex, :index
  end

  scope "/", PhysioWeb do
    pipe_through [:browser]

    delete "/admins/log_out", AdminSessionController, :delete
    get "/admins/confirm", AdminConfirmationController, :new
    post "/admins/confirm", AdminConfirmationController, :create
    get "/admins/confirm/:token", AdminConfirmationController, :edit
    post "/admins/confirm/:token", AdminConfirmationController, :update
  end
end
