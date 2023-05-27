defmodule Physio.CategoriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Physio.Categories` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Physio.Categories.create_category()

    category
  end

  @doc """
  Generate a sub_category.
  """
  def sub_category_fixture(attrs \\ %{}) do
    {:ok, sub_category} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Physio.Categories.create_sub_category()

    sub_category
  end

  @doc """
  Generate a doctor_category.
  """
  def doctor_category_fixture(attrs \\ %{}) do
    {:ok, doctor_category} =
      attrs
      |> Enum.into(%{

      })
      |> Physio.Categories.create_doctor_category()

    doctor_category
  end
end
