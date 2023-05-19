defmodule Physio.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Physio.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Physio.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def unique_doctor_email, do: "doctor#{System.unique_integer()}@example.com"
  def valid_doctor_password, do: "hello world!"

  def valid_doctor_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_doctor_email(),
      password: valid_doctor_password()
    })
  end

  def doctor_fixture(attrs \\ %{}) do
    {:ok, doctor} =
      attrs
      |> valid_doctor_attributes()
      |> Physio.Accounts.register_doctor()

    doctor
  end

  def extract_doctor_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  @doc """
  Generate a doctor_profile.
  """
  def doctor_profile_fixture(attrs \\ %{}) do
    {:ok, doctor_profile} =
      attrs
      |> Enum.into(%{
        first_name: "some first_name",
        last_name: "some last_name",
        profile_img: "some profile_img"
      })
      |> Physio.Accounts.create_doctor_profile()

    doctor_profile
  end

  @doc """
  Generate a user_profile.
  """
  def user_profile_fixture(attrs \\ %{}) do
    {:ok, user_profile} =
      attrs
      |> Enum.into(%{
        first_name: "some first_name",
        last_name: "some last_name",
        profile_img: "some profile_img"
      })
      |> Physio.Accounts.create_user_profile()

    user_profile
  end
end
