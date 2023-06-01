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

  def list_sub_categories_by_category(category_id) do
    (from sc in SubCategory,
      where: sc.category_id == ^category_id)
    |> Repo.all()
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

  alias Physio.Categories.DoctorCategory

  @doc """
  Returns the list of doctor_categories.

  ## Examples

      iex> list_doctor_categories()
      [%DoctorCategory{}, ...]

  """
  def list_doctor_categories do
    Repo.all(DoctorCategory)
  end

  @doc """
  Gets a single doctor_category.

  Raises `Ecto.NoResultsError` if the Doctor category does not exist.

  ## Examples

      iex> get_doctor_category!(123)
      %DoctorCategory{}

      iex> get_doctor_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_doctor_category!(id), do: Repo.get!(DoctorCategory, id)

  @doc """
  Creates a doctor_category.

  ## Examples

      iex> create_doctor_category(%{field: value})
      {:ok, %DoctorCategory{}}

      iex> create_doctor_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_doctor_category(attrs \\ %{}) do
    %DoctorCategory{}
    |> DoctorCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a doctor_category.

  ## Examples

      iex> update_doctor_category(doctor_category, %{field: new_value})
      {:ok, %DoctorCategory{}}

      iex> update_doctor_category(doctor_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_doctor_category(%DoctorCategory{} = doctor_category, attrs) do
    doctor_category
    |> DoctorCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a doctor_category.

  ## Examples

      iex> delete_doctor_category(doctor_category)
      {:ok, %DoctorCategory{}}

      iex> delete_doctor_category(doctor_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_doctor_category(%DoctorCategory{} = doctor_category) do
    Repo.delete(doctor_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking doctor_category changes.

  ## Examples

      iex> change_doctor_category(doctor_category)
      %Ecto.Changeset{data: %DoctorCategory{}}

  """
  def change_doctor_category(%DoctorCategory{} = doctor_category, attrs \\ %{}) do
    DoctorCategory.changeset(doctor_category, attrs)
  end

  def get_categories_by_doctor_id(doctor_id) do
    from(
      dc in DoctorCategory,
      where: dc.doctor_id == ^doctor_id,
      join: c in Category, on: dc.category_id == c.id,
      join: sc in SubCategory, on: dc.sub_category_id == sc.id,
      select: %{doctor_category: dc, category: c, sub_category: sc}
    )
    |> Repo.all()
  end
end
