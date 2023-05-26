defmodule Physio.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Physio.Repo

  alias Physio.Accounts.{User, UserToken, UserNotifier}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]))
  end

  @doc """
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_update_email_instructions(user, current_email, &Routes.user_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &Routes.user_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &Routes.user_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &Routes.user_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  alias Physio.Accounts.{Doctor, DoctorToken, DoctorNotifier}

  ## Database getters

  @doc """
  Gets a doctor by email.

  ## Examples

      iex> get_doctor_by_email("foo@example.com")
      %Doctor{}

      iex> get_doctor_by_email("unknown@example.com")
      nil

  """
  def get_doctor_by_email(email) when is_binary(email) do
    Repo.get_by(Doctor, email: email)
  end

  @doc """
  Gets a doctor by email and password.

  ## Examples

      iex> get_doctor_by_email_and_password("foo@example.com", "correct_password")
      %Doctor{}

      iex> get_doctor_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_doctor_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    doctor = Repo.get_by(Doctor, email: email)
    if Doctor.valid_password?(doctor, password), do: doctor
  end

  def list_doctor() do
    Doctor
    |> preload(:doctor_profile)
    |> Repo.all()
  end

  @doc """
  Gets a single doctor.

  Raises `Ecto.NoResultsError` if the Doctor does not exist.

  ## Examples

      iex> get_doctor!(123)
      %Doctor{}

      iex> get_doctor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_doctor!(id), do: Doctor |> preload(:doctor_profile) |> Repo.get!(id)

  ## Doctor registration

  @doc """
  Registers a doctor.

  ## Examples

      iex> register_doctor(%{field: value})
      {:ok, %Doctor{}}

      iex> register_doctor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_doctor(attrs) do
    %Doctor{}
    |> Doctor.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking doctor changes.

  ## Examples

      iex> change_doctor_registration(doctor)
      %Ecto.Changeset{data: %Doctor{}}

  """
  def change_doctor_registration(%Doctor{} = doctor, attrs \\ %{}) do
    Doctor.registration_changeset(doctor, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the doctor email.

  ## Examples

      iex> change_doctor_email(doctor)
      %Ecto.Changeset{data: %Doctor{}}

  """
  def change_doctor_email(doctor, attrs \\ %{}) do
    Doctor.email_changeset(doctor, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_doctor_email(doctor, "valid password", %{email: ...})
      {:ok, %Doctor{}}

      iex> apply_doctor_email(doctor, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_doctor_email(doctor, password, attrs) do
    doctor
    |> Doctor.email_changeset(attrs)
    |> Doctor.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the doctor email using the given token.

  If the token matches, the doctor email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_doctor_email(doctor, token) do
    context = "change:#{doctor.email}"

    with {:ok, query} <- DoctorToken.verify_change_email_token_query(token, context),
         %DoctorToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(doctor_email_multi(doctor, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp doctor_email_multi(doctor, email, context) do
    changeset =
      doctor
      |> Doctor.email_changeset(%{email: email})
      |> Doctor.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:doctor, changeset)
    |> Ecto.Multi.delete_all(:tokens, DoctorToken.doctor_and_contexts_query(doctor, [context]))
  end

  @doc """
  Delivers the update email instructions to the given doctor.

  ## Examples

      iex> deliver_update_email_instructions(doctor, current_email, &Routes.doctor_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%Doctor{} = doctor, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, doctor_token} = DoctorToken.build_email_token(doctor, "change:#{current_email}")

    Repo.insert!(doctor_token)
    DoctorNotifier.deliver_update_email_instructions(doctor, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the doctor password.

  ## Examples

      iex> change_doctor_password(doctor)
      %Ecto.Changeset{data: %Doctor{}}

  """
  def change_doctor_password(doctor, attrs \\ %{}) do
    Doctor.password_changeset(doctor, attrs, hash_password: false)
  end

  @doc """
  Updates the doctor password.

  ## Examples

      iex> update_doctor_password(doctor, "valid password", %{password: ...})
      {:ok, %Doctor{}}

      iex> update_doctor_password(doctor, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_doctor_password(doctor, password, attrs) do
    changeset =
      doctor
      |> Doctor.password_changeset(attrs)
      |> Doctor.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:doctor, changeset)
    |> Ecto.Multi.delete_all(:tokens, DoctorToken.doctor_and_contexts_query(doctor, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{doctor: doctor}} -> {:ok, doctor}
      {:error, :doctor, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_doctor_session_token(doctor) do
    {token, doctor_token} = DoctorToken.build_session_token(doctor)
    Repo.insert!(doctor_token)
    token
  end

  @doc """
  Gets the doctor with the given signed token.
  """
  def get_doctor_by_session_token(token) do
    {:ok, query} = DoctorToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(DoctorToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given doctor.

  ## Examples

      iex> deliver_doctor_confirmation_instructions(doctor, &Routes.doctor_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_doctor_confirmation_instructions(confirmed_doctor, &Routes.doctor_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  def deliver_doctor_confirmation_instructions(%Doctor{} = doctor, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if doctor.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, doctor_token} = DoctorToken.build_email_token(doctor, "confirm")
      Repo.insert!(doctor_token)
      DoctorNotifier.deliver_confirmation_instructions(doctor, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a doctor by the given token.

  If the token matches, the doctor account is marked as confirmed
  and the token is deleted.
  """
  def confirm_doctor(token) do
    with {:ok, query} <- DoctorToken.verify_email_token_query(token, "confirm"),
         %Doctor{} = doctor <- Repo.one(query),
         {:ok, %{doctor: doctor}} <- Repo.transaction(confirm_doctor_multi(doctor)) do
      {:ok, doctor}
    else
      _ -> :error
    end
  end

  defp confirm_doctor_multi(doctor) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:doctor, Doctor.confirm_changeset(doctor))
    |> Ecto.Multi.delete_all(:tokens, DoctorToken.doctor_and_contexts_query(doctor, ["confirm"]))
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given doctor.

  ## Examples

      iex> deliver_doctor_reset_password_instructions(doctor, &Routes.doctor_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_doctor_reset_password_instructions(%Doctor{} = doctor, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, doctor_token} = DoctorToken.build_email_token(doctor, "reset_password")
    Repo.insert!(doctor_token)
    DoctorNotifier.deliver_reset_password_instructions(doctor, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the doctor by reset password token.

  ## Examples

      iex> get_doctor_by_reset_password_token("validtoken")
      %Doctor{}

      iex> get_doctor_by_reset_password_token("invalidtoken")
      nil

  """
  def get_doctor_by_reset_password_token(token) do
    with {:ok, query} <- DoctorToken.verify_email_token_query(token, "reset_password"),
         %Doctor{} = doctor <- Repo.one(query) do
      doctor
    else
      _ -> nil
    end
  end

  @doc """
  Resets the doctor password.

  ## Examples

      iex> reset_doctor_password(doctor, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Doctor{}}

      iex> reset_doctor_password(doctor, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_doctor_password(doctor, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:doctor, Doctor.password_changeset(doctor, attrs))
    |> Ecto.Multi.delete_all(:tokens, DoctorToken.doctor_and_contexts_query(doctor, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{doctor: doctor}} -> {:ok, doctor}
      {:error, :doctor, changeset, _} -> {:error, changeset}
    end
  end

  alias Physio.Accounts.DoctorProfile

  @doc """
  Returns the list of doctor_profiles.

  ## Examples

      iex> list_doctor_profiles()
      [%DoctorProfile{}, ...]

  """
  def list_doctor_profiles do
    Repo.all(DoctorProfile)
  end

  @doc """
  Gets a single doctor_profile.

  Raises `Ecto.NoResultsError` if the Doctor profile does not exist.

  ## Examples

      iex> get_doctor_profile!(123)
      %DoctorProfile{}

      iex> get_doctor_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_doctor_profile!(id), do: Repo.get!(DoctorProfile, id)

  @doc """
  Creates a doctor_profile.

  ## Examples

      iex> create_doctor_profile(%{field: value})
      {:ok, %DoctorProfile{}}

      iex> create_doctor_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_doctor_profile(attrs \\ %{}) do
    %DoctorProfile{}
    |> DoctorProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a doctor_profile.

  ## Examples

      iex> update_doctor_profile(doctor_profile, %{field: new_value})
      {:ok, %DoctorProfile{}}

      iex> update_doctor_profile(doctor_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_doctor_profile(%DoctorProfile{} = doctor_profile, attrs) do
    doctor_profile
    |> DoctorProfile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a doctor_profile.

  ## Examples

      iex> delete_doctor_profile(doctor_profile)
      {:ok, %DoctorProfile{}}

      iex> delete_doctor_profile(doctor_profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_doctor_profile(%DoctorProfile{} = doctor_profile) do
    Repo.delete(doctor_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking doctor_profile changes.

  ## Examples

      iex> change_doctor_profile(doctor_profile)
      %Ecto.Changeset{data: %DoctorProfile{}}

  """
  def change_doctor_profile(%DoctorProfile{} = doctor_profile, attrs \\ %{}) do
    DoctorProfile.changeset(doctor_profile, attrs)
  end

  alias Physio.Accounts.UserProfile

  @doc """
  Returns the list of user_profiles.

  ## Examples

      iex> list_user_profiles()
      [%UserProfile{}, ...]

  """
  def list_user_profiles do
    Repo.all(UserProfile)
  end

  @doc """
  Gets a single user_profile.

  Raises `Ecto.NoResultsError` if the User profile does not exist.

  ## Examples

      iex> get_user_profile!(123)
      %UserProfile{}

      iex> get_user_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_profile!(id), do: Repo.get!(UserProfile, id)

  @doc """
  Creates a user_profile.

  ## Examples

      iex> create_user_profile(%{field: value})
      {:ok, %UserProfile{}}

      iex> create_user_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_profile(attrs \\ %{}) do
    %UserProfile{}
    |> UserProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_profile.

  ## Examples

      iex> update_user_profile(user_profile, %{field: new_value})
      {:ok, %UserProfile{}}

      iex> update_user_profile(user_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_profile(%UserProfile{} = user_profile, attrs) do
    user_profile
    |> UserProfile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_profile.

  ## Examples

      iex> delete_user_profile(user_profile)
      {:ok, %UserProfile{}}

      iex> delete_user_profile(user_profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_profile(%UserProfile{} = user_profile) do
    Repo.delete(user_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_profile changes.

  ## Examples

      iex> change_user_profile(user_profile)
      %Ecto.Changeset{data: %UserProfile{}}

  """
  def change_user_profile(%UserProfile{} = user_profile, attrs \\ %{}) do
    UserProfile.changeset(user_profile, attrs)
  end

  def update_user_with_user_profile(%User{user_profile: %UserProfile{}} = user, attrs \\ %{}) do
    IO.inspect(user, label: "user")
    user
    |> user_changeset(attrs)
    |> Repo.update()
  end

  def user_changeset(%User{} = user, attrs \\ %{}) do
    User.user_update_changeset(user, attrs)
  end
end
