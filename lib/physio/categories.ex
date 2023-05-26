defmodule Physio.Categories do
  @moduledoc """
  The Categories context.
  """

  import Ecto.Query, warn: false
  alias Physio.Repo

  alias Physio.Categories.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  alias Physio.Categories.SubCategory

  @doc """
  Returns the list of sub_categories.

  ## Examples

      iex> list_sub_categories()
      [%SubCategory{}, ...]

  """
  def list_sub_categories do
    Repo.all(SubCategory)
  end

  @doc """
  Gets a single sub_category.

  Raises `Ecto.NoResultsError` if the Sub category does not exist.

  ## Examples

      iex> get_sub_category!(123)
      %SubCategory{}

      iex> get_sub_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sub_category!(id), do: Repo.get!(SubCategory, id)

  @doc """
  Creates a sub_category.

  ## Examples

      iex> create_sub_category(%{field: value})
      {:ok, %SubCategory{}}

      iex> create_sub_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sub_category(attrs \\ %{}) do
    %SubCategory{}
    |> SubCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sub_category.

  ## Examples

      iex> update_sub_category(sub_category, %{field: new_value})
      {:ok, %SubCategory{}}

      iex> update_sub_category(sub_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sub_category(%SubCategory{} = sub_category, attrs) do
    sub_category
    |> SubCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sub_category.

  ## Examples

      iex> delete_sub_category(sub_category)
      {:ok, %SubCategory{}}

      iex> delete_sub_category(sub_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sub_category(%SubCategory{} = sub_category) do
    Repo.delete(sub_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sub_category changes.

  ## Examples

      iex> change_sub_category(sub_category)
      %Ecto.Changeset{data: %SubCategory{}}

  """
  def change_sub_category(%SubCategory{} = sub_category, attrs \\ %{}) do
    SubCategory.changeset(sub_category, attrs)
  end
end
