defmodule Physio.AccountsTest do
  use Physio.DataCase

  alias Physio.Accounts

  import Physio.AccountsFixtures
  alias Physio.Accounts.{User, UserToken}

  describe "get_user_by_email/1" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email("unknown@example.com")
    end

    test "returns the user if the email exists" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user_by_email(user.email)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = user_fixture()
      refute Accounts.get_user_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      %{id: id} = user = user_fixture()

      assert %User{id: ^id} =
               Accounts.get_user_by_email_and_password(user.email, valid_user_password())
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end

    test "returns the user with the given id" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Accounts.register_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = user_fixture()
      {:error, changeset} = Accounts.register_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Accounts.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers users with a hashed password" do
      email = unique_user_email()
      {:ok, user} = Accounts.register_user(valid_user_attributes(email: email))
      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end
  end

  describe "change_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_registration(%User{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_user_email()
      password = valid_user_password()

      changeset =
        Accounts.change_user_registration(
          %User{},
          valid_user_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_user_email/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_email(%User{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_user_email/3" do
    setup do
      %{user: user_fixture()}
    end

    test "requires email to change", %{user: user} do
      {:error, changeset} = Accounts.apply_user_email(user, valid_user_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{user: user} do
      %{email: email} = user_fixture()

      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, "invalid", %{email: unique_user_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{user: user} do
      email = unique_user_email()
      {:ok, user} = Accounts.apply_user_email(user, valid_user_password(), %{email: email})
      assert user.email == email
      assert Accounts.get_user!(user.id).email != email
    end
  end

  describe "deliver_update_email_instructions/3" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "change:current@example.com"
    end
  end

  describe "update_user_email/2" do
    setup do
      user = user_fixture()
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{user: user, token: token, email: email}
    end

    test "updates the email with a valid token", %{user: user, token: token, email: email} do
      assert Accounts.update_user_email(user, token) == :ok
      changed_user = Repo.get!(User, user.id)
      assert changed_user.email != user.email
      assert changed_user.email == email
      assert changed_user.confirmed_at
      assert changed_user.confirmed_at != user.confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email with invalid token", %{user: user} do
      assert Accounts.update_user_email(user, "oops") == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if user email changed", %{user: user, token: token} do
      assert Accounts.update_user_email(%{user | email: "current@example.com"}, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.update_user_email(user, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "change_user_password/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_password(%User{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_user_password(%User{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_user_password/3" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, "invalid", %{password: valid_user_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{user: user} do
      {:ok, user} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      assert is_nil(user.password)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)

      {:ok, _} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "deliver_user_confirmation_instructions/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "confirm"
    end
  end

  describe "confirm_user/1" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "confirms the email with a valid token", %{user: user, token: token} do
      assert {:ok, confirmed_user} = Accounts.confirm_user(token)
      assert confirmed_user.confirmed_at
      assert confirmed_user.confirmed_at != user.confirmed_at
      assert Repo.get!(User, user.id).confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm with invalid token", %{user: user} do
      assert Accounts.confirm_user("oops") == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.confirm_user(token) == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "deliver_user_reset_password_instructions/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "reset_password"
    end
  end

  describe "get_user_by_reset_password_token/1" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "returns the user with valid token", %{user: %{id: id}, token: token} do
      assert %User{id: ^id} = Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: id)
    end

    test "does not return the user with invalid token", %{user: user} do
      refute Accounts.get_user_by_reset_password_token("oops")
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "reset_user_password/2" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.reset_user_password(user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.reset_user_password(user, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{user: user} do
      {:ok, updated_user} = Accounts.reset_user_password(user, %{password: "new valid password"})
      assert is_nil(updated_user.password)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)
      {:ok, _} = Accounts.reset_user_password(user, %{password: "new valid password"})
      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end

  import Physio.AccountsFixtures
  alias Physio.Accounts.{Doctor, DoctorToken}

  describe "get_doctor_by_email/1" do
    test "does not return the doctor if the email does not exist" do
      refute Accounts.get_doctor_by_email("unknown@example.com")
    end

    test "returns the doctor if the email exists" do
      %{id: id} = doctor = doctor_fixture()
      assert %Doctor{id: ^id} = Accounts.get_doctor_by_email(doctor.email)
    end
  end

  describe "get_doctor_by_email_and_password/2" do
    test "does not return the doctor if the email does not exist" do
      refute Accounts.get_doctor_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the doctor if the password is not valid" do
      doctor = doctor_fixture()
      refute Accounts.get_doctor_by_email_and_password(doctor.email, "invalid")
    end

    test "returns the doctor if the email and password are valid" do
      %{id: id} = doctor = doctor_fixture()

      assert %Doctor{id: ^id} =
               Accounts.get_doctor_by_email_and_password(doctor.email, valid_doctor_password())
    end
  end

  describe "get_doctor!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_doctor!(-1)
      end
    end

    test "returns the doctor with the given id" do
      %{id: id} = doctor = doctor_fixture()
      assert %Doctor{id: ^id} = Accounts.get_doctor!(doctor.id)
    end
  end

  describe "register_doctor/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Accounts.register_doctor(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Accounts.register_doctor(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_doctor(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = doctor_fixture()
      {:error, changeset} = Accounts.register_doctor(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Accounts.register_doctor(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers doctors with a hashed password" do
      email = unique_doctor_email()
      {:ok, doctor} = Accounts.register_doctor(valid_doctor_attributes(email: email))
      assert doctor.email == email
      assert is_binary(doctor.hashed_password)
      assert is_nil(doctor.confirmed_at)
      assert is_nil(doctor.password)
    end
  end

  describe "change_doctor_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_doctor_registration(%Doctor{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_doctor_email()
      password = valid_doctor_password()

      changeset =
        Accounts.change_doctor_registration(
          %Doctor{},
          valid_doctor_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_doctor_email/2" do
    test "returns a doctor changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_doctor_email(%Doctor{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_doctor_email/3" do
    setup do
      %{doctor: doctor_fixture()}
    end

    test "requires email to change", %{doctor: doctor} do
      {:error, changeset} = Accounts.apply_doctor_email(doctor, valid_doctor_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{doctor: doctor} do
      {:error, changeset} =
        Accounts.apply_doctor_email(doctor, valid_doctor_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{doctor: doctor} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.apply_doctor_email(doctor, valid_doctor_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{doctor: doctor} do
      %{email: email} = doctor_fixture()

      {:error, changeset} =
        Accounts.apply_doctor_email(doctor, valid_doctor_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{doctor: doctor} do
      {:error, changeset} =
        Accounts.apply_doctor_email(doctor, "invalid", %{email: unique_doctor_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{doctor: doctor} do
      email = unique_doctor_email()
      {:ok, doctor} = Accounts.apply_doctor_email(doctor, valid_doctor_password(), %{email: email})
      assert doctor.email == email
      assert Accounts.get_doctor!(doctor.id).email != email
    end
  end

  describe "deliver_update_email_instructions/3" do
    setup do
      %{doctor: doctor_fixture()}
    end

    test "sends token through notification", %{doctor: doctor} do
      token =
        extract_doctor_token(fn url ->
          Accounts.deliver_update_email_instructions(doctor, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert doctor_token = Repo.get_by(DoctorToken, token: :crypto.hash(:sha256, token))
      assert doctor_token.doctor_id == doctor.id
      assert doctor_token.sent_to == doctor.email
      assert doctor_token.context == "change:current@example.com"
    end
  end

  describe "update_doctor_email/2" do
    setup do
      doctor = doctor_fixture()
      email = unique_doctor_email()

      token =
        extract_doctor_token(fn url ->
          Accounts.deliver_update_email_instructions(%{doctor | email: email}, doctor.email, url)
        end)

      %{doctor: doctor, token: token, email: email}
    end

    test "updates the email with a valid token", %{doctor: doctor, token: token, email: email} do
      assert Accounts.update_doctor_email(doctor, token) == :ok
      changed_doctor = Repo.get!(Doctor, doctor.id)
      assert changed_doctor.email != doctor.email
      assert changed_doctor.email == email
      assert changed_doctor.confirmed_at
      assert changed_doctor.confirmed_at != doctor.confirmed_at
      refute Repo.get_by(DoctorToken, doctor_id: doctor.id)
    end

    test "does not update email with invalid token", %{doctor: doctor} do
      assert Accounts.update_doctor_email(doctor, "oops") == :error
      assert Repo.get!(Doctor, doctor.id).email == doctor.email
      assert Repo.get_by(DoctorToken, doctor_id: doctor.id)
    end

    test "does not update email if doctor email changed", %{doctor: doctor, token: token} do
      assert Accounts.update_doctor_email(%{doctor | email: "current@example.com"}, token) == :error
      assert Repo.get!(Doctor, doctor.id).email == doctor.email
      assert Repo.get_by(DoctorToken, doctor_id: doctor.id)
    end

    test "does not update email if token expired", %{doctor: doctor, token: token} do
      {1, nil} = Repo.update_all(DoctorToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.update_doctor_email(doctor, token) == :error
      assert Repo.get!(Doctor, doctor.id).email == doctor.email
      assert Repo.get_by(DoctorToken, doctor_id: doctor.id)
    end
  end

  describe "change_doctor_password/2" do
    test "returns a doctor changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_doctor_password(%Doctor{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_doctor_password(%Doctor{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_doctor_password/3" do
    setup do
      %{doctor: doctor_fixture()}
    end

    test "validates password", %{doctor: doctor} do
      {:error, changeset} =
        Accounts.update_doctor_password(doctor, valid_doctor_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{doctor: doctor} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_doctor_password(doctor, valid_doctor_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{doctor: doctor} do
      {:error, changeset} =
        Accounts.update_doctor_password(doctor, "invalid", %{password: valid_doctor_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{doctor: doctor} do
      {:ok, doctor} =
        Accounts.update_doctor_password(doctor, valid_doctor_password(), %{
          password: "new valid password"
        })

      assert is_nil(doctor.password)
      assert Accounts.get_doctor_by_email_and_password(doctor.email, "new valid password")
    end

    test "deletes all tokens for the given doctor", %{doctor: doctor} do
      _ = Accounts.generate_doctor_session_token(doctor)

      {:ok, _} =
        Accounts.update_doctor_password(doctor, valid_doctor_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(DoctorToken, doctor_id: doctor.id)
    end
  end

  describe "generate_doctor_session_token/1" do
    setup do
      %{doctor: doctor_fixture()}
    end

    test "generates a token", %{doctor: doctor} do
      token = Accounts.generate_doctor_session_token(doctor)
      assert doctor_token = Repo.get_by(DoctorToken, token: token)
      assert doctor_token.context == "session"

      # Creating the same token for another doctor should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%DoctorToken{
          token: doctor_token.token,
          doctor_id: doctor_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_doctor_by_session_token/1" do
    setup do
      doctor = doctor_fixture()
      token = Accounts.generate_doctor_session_token(doctor)
      %{doctor: doctor, token: token}
    end

    test "returns doctor by token", %{doctor: doctor, token: token} do
      assert session_doctor = Accounts.get_doctor_by_session_token(token)
      assert session_doctor.id == doctor.id
    end

    test "does not return doctor for invalid token" do
      refute Accounts.get_doctor_by_session_token("oops")
    end

    test "does not return doctor for expired token", %{token: token} do
      {1, nil} = Repo.update_all(DoctorToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_doctor_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      doctor = doctor_fixture()
      token = Accounts.generate_doctor_session_token(doctor)
      assert Accounts.delete_session_token(token) == :ok
      refute Accounts.get_doctor_by_session_token(token)
    end
  end

  describe "deliver_doctor_confirmation_instructions/2" do
    setup do
      %{doctor: doctor_fixture()}
    end

    test "sends token through notification", %{doctor: doctor} do
      token =
        extract_doctor_token(fn url ->
          Accounts.deliver_doctor_confirmation_instructions(doctor, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert doctor_token = Repo.get_by(DoctorToken, token: :crypto.hash(:sha256, token))
      assert doctor_token.doctor_id == doctor.id
      assert doctor_token.sent_to == doctor.email
      assert doctor_token.context == "confirm"
    end
  end

  describe "confirm_doctor/1" do
    setup do
      doctor = doctor_fixture()

      token =
        extract_doctor_token(fn url ->
          Accounts.deliver_doctor_confirmation_instructions(doctor, url)
        end)

      %{doctor: doctor, token: token}
    end

    test "confirms the email with a valid token", %{doctor: doctor, token: token} do
      assert {:ok, confirmed_doctor} = Accounts.confirm_doctor(token)
      assert confirmed_doctor.confirmed_at
      assert confirmed_doctor.confirmed_at != doctor.confirmed_at
      assert Repo.get!(Doctor, doctor.id).confirmed_at
      refute Repo.get_by(DoctorToken, doctor_id: doctor.id)
    end

    test "does not confirm with invalid token", %{doctor: doctor} do
      assert Accounts.confirm_doctor("oops") == :error
      refute Repo.get!(Doctor, doctor.id).confirmed_at
      assert Repo.get_by(DoctorToken, doctor_id: doctor.id)
    end

    test "does not confirm email if token expired", %{doctor: doctor, token: token} do
      {1, nil} = Repo.update_all(DoctorToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.confirm_doctor(token) == :error
      refute Repo.get!(Doctor, doctor.id).confirmed_at
      assert Repo.get_by(DoctorToken, doctor_id: doctor.id)
    end
  end

  describe "deliver_doctor_reset_password_instructions/2" do
    setup do
      %{doctor: doctor_fixture()}
    end

    test "sends token through notification", %{doctor: doctor} do
      token =
        extract_doctor_token(fn url ->
          Accounts.deliver_doctor_reset_password_instructions(doctor, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert doctor_token = Repo.get_by(DoctorToken, token: :crypto.hash(:sha256, token))
      assert doctor_token.doctor_id == doctor.id
      assert doctor_token.sent_to == doctor.email
      assert doctor_token.context == "reset_password"
    end
  end

  describe "get_doctor_by_reset_password_token/1" do
    setup do
      doctor = doctor_fixture()

      token =
        extract_doctor_token(fn url ->
          Accounts.deliver_doctor_reset_password_instructions(doctor, url)
        end)

      %{doctor: doctor, token: token}
    end

    test "returns the doctor with valid token", %{doctor: %{id: id}, token: token} do
      assert %Doctor{id: ^id} = Accounts.get_doctor_by_reset_password_token(token)
      assert Repo.get_by(DoctorToken, doctor_id: id)
    end

    test "does not return the doctor with invalid token", %{doctor: doctor} do
      refute Accounts.get_doctor_by_reset_password_token("oops")
      assert Repo.get_by(DoctorToken, doctor_id: doctor.id)
    end

    test "does not return the doctor if token expired", %{doctor: doctor, token: token} do
      {1, nil} = Repo.update_all(DoctorToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_doctor_by_reset_password_token(token)
      assert Repo.get_by(DoctorToken, doctor_id: doctor.id)
    end
  end

  describe "reset_doctor_password/2" do
    setup do
      %{doctor: doctor_fixture()}
    end

    test "validates password", %{doctor: doctor} do
      {:error, changeset} =
        Accounts.reset_doctor_password(doctor, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{doctor: doctor} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.reset_doctor_password(doctor, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{doctor: doctor} do
      {:ok, updated_doctor} = Accounts.reset_doctor_password(doctor, %{password: "new valid password"})
      assert is_nil(updated_doctor.password)
      assert Accounts.get_doctor_by_email_and_password(doctor.email, "new valid password")
    end

    test "deletes all tokens for the given doctor", %{doctor: doctor} do
      _ = Accounts.generate_doctor_session_token(doctor)
      {:ok, _} = Accounts.reset_doctor_password(doctor, %{password: "new valid password"})
      refute Repo.get_by(DoctorToken, doctor_id: doctor.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%Doctor{password: "123456"}) =~ "password: \"123456\""
    end
  end

  describe "doctor_profiles" do
    alias Physio.Accounts.DoctorProfile

    import Physio.AccountsFixtures

    @invalid_attrs %{first_name: nil, last_name: nil, profile_img: nil}

    test "list_doctor_profiles/0 returns all doctor_profiles" do
      doctor_profile = doctor_profile_fixture()
      assert Accounts.list_doctor_profiles() == [doctor_profile]
    end

    test "get_doctor_profile!/1 returns the doctor_profile with given id" do
      doctor_profile = doctor_profile_fixture()
      assert Accounts.get_doctor_profile!(doctor_profile.id) == doctor_profile
    end

    test "create_doctor_profile/1 with valid data creates a doctor_profile" do
      valid_attrs = %{first_name: "some first_name", last_name: "some last_name", profile_img: "some profile_img"}

      assert {:ok, %DoctorProfile{} = doctor_profile} = Accounts.create_doctor_profile(valid_attrs)
      assert doctor_profile.first_name == "some first_name"
      assert doctor_profile.last_name == "some last_name"
      assert doctor_profile.profile_img == "some profile_img"
    end

    test "create_doctor_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_doctor_profile(@invalid_attrs)
    end

    test "update_doctor_profile/2 with valid data updates the doctor_profile" do
      doctor_profile = doctor_profile_fixture()
      update_attrs = %{first_name: "some updated first_name", last_name: "some updated last_name", profile_img: "some updated profile_img"}

      assert {:ok, %DoctorProfile{} = doctor_profile} = Accounts.update_doctor_profile(doctor_profile, update_attrs)
      assert doctor_profile.first_name == "some updated first_name"
      assert doctor_profile.last_name == "some updated last_name"
      assert doctor_profile.profile_img == "some updated profile_img"
    end

    test "update_doctor_profile/2 with invalid data returns error changeset" do
      doctor_profile = doctor_profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_doctor_profile(doctor_profile, @invalid_attrs)
      assert doctor_profile == Accounts.get_doctor_profile!(doctor_profile.id)
    end

    test "delete_doctor_profile/1 deletes the doctor_profile" do
      doctor_profile = doctor_profile_fixture()
      assert {:ok, %DoctorProfile{}} = Accounts.delete_doctor_profile(doctor_profile)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_doctor_profile!(doctor_profile.id) end
    end

    test "change_doctor_profile/1 returns a doctor_profile changeset" do
      doctor_profile = doctor_profile_fixture()
      assert %Ecto.Changeset{} = Accounts.change_doctor_profile(doctor_profile)
    end
  end

  describe "user_profiles" do
    alias Physio.Accounts.UserProfile

    import Physio.AccountsFixtures

    @invalid_attrs %{first_name: nil, last_name: nil, profile_img: nil}

    test "list_user_profiles/0 returns all user_profiles" do
      user_profile = user_profile_fixture()
      assert Accounts.list_user_profiles() == [user_profile]
    end

    test "get_user_profile!/1 returns the user_profile with given id" do
      user_profile = user_profile_fixture()
      assert Accounts.get_user_profile!(user_profile.id) == user_profile
    end

    test "create_user_profile/1 with valid data creates a user_profile" do
      valid_attrs = %{first_name: "some first_name", last_name: "some last_name", profile_img: "some profile_img"}

      assert {:ok, %UserProfile{} = user_profile} = Accounts.create_user_profile(valid_attrs)
      assert user_profile.first_name == "some first_name"
      assert user_profile.last_name == "some last_name"
      assert user_profile.profile_img == "some profile_img"
    end

    test "create_user_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_profile(@invalid_attrs)
    end

    test "update_user_profile/2 with valid data updates the user_profile" do
      user_profile = user_profile_fixture()
      update_attrs = %{first_name: "some updated first_name", last_name: "some updated last_name", profile_img: "some updated profile_img"}

      assert {:ok, %UserProfile{} = user_profile} = Accounts.update_user_profile(user_profile, update_attrs)
      assert user_profile.first_name == "some updated first_name"
      assert user_profile.last_name == "some updated last_name"
      assert user_profile.profile_img == "some updated profile_img"
    end

    test "update_user_profile/2 with invalid data returns error changeset" do
      user_profile = user_profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user_profile(user_profile, @invalid_attrs)
      assert user_profile == Accounts.get_user_profile!(user_profile.id)
    end

    test "delete_user_profile/1 deletes the user_profile" do
      user_profile = user_profile_fixture()
      assert {:ok, %UserProfile{}} = Accounts.delete_user_profile(user_profile)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_profile!(user_profile.id) end
    end

    test "change_user_profile/1 returns a user_profile changeset" do
      user_profile = user_profile_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user_profile(user_profile)
    end
  end
end
