defmodule Physio.CategoriesTest do
  use Physio.DataCase

  alias Physio.Categories

  describe "categories" do
    alias Physio.Categories.Category

    import Physio.CategoriesFixtures

    @invalid_attrs %{name: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Categories.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Categories.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Category{} = category} = Categories.create_category(valid_attrs)
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Categories.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Category{} = category} = Categories.update_category(category, update_attrs)
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Categories.update_category(category, @invalid_attrs)
      assert category == Categories.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Categories.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Categories.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Categories.change_category(category)
    end
  end

  describe "sub_categories" do
    alias Physio.Categories.SubCategory

    import Physio.CategoriesFixtures

    @invalid_attrs %{name: nil}

    test "list_sub_categories/0 returns all sub_categories" do
      sub_category = sub_category_fixture()
      assert Categories.list_sub_categories() == [sub_category]
    end

    test "get_sub_category!/1 returns the sub_category with given id" do
      sub_category = sub_category_fixture()
      assert Categories.get_sub_category!(sub_category.id) == sub_category
    end

    test "create_sub_category/1 with valid data creates a sub_category" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %SubCategory{} = sub_category} = Categories.create_sub_category(valid_attrs)
      assert sub_category.name == "some name"
    end

    test "create_sub_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Categories.create_sub_category(@invalid_attrs)
    end

    test "update_sub_category/2 with valid data updates the sub_category" do
      sub_category = sub_category_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %SubCategory{} = sub_category} = Categories.update_sub_category(sub_category, update_attrs)
      assert sub_category.name == "some updated name"
    end

    test "update_sub_category/2 with invalid data returns error changeset" do
      sub_category = sub_category_fixture()
      assert {:error, %Ecto.Changeset{}} = Categories.update_sub_category(sub_category, @invalid_attrs)
      assert sub_category == Categories.get_sub_category!(sub_category.id)
    end

    test "delete_sub_category/1 deletes the sub_category" do
      sub_category = sub_category_fixture()
      assert {:ok, %SubCategory{}} = Categories.delete_sub_category(sub_category)
      assert_raise Ecto.NoResultsError, fn -> Categories.get_sub_category!(sub_category.id) end
    end

    test "change_sub_category/1 returns a sub_category changeset" do
      sub_category = sub_category_fixture()
      assert %Ecto.Changeset{} = Categories.change_sub_category(sub_category)
    end
  end

  describe "doctor_categories" do
    alias Physio.Categories.DoctorCategory

    import Physio.CategoriesFixtures

    @invalid_attrs %{}

    test "list_doctor_categories/0 returns all doctor_categories" do
      doctor_category = doctor_category_fixture()
      assert Categories.list_doctor_categories() == [doctor_category]
    end

    test "get_doctor_category!/1 returns the doctor_category with given id" do
      doctor_category = doctor_category_fixture()
      assert Categories.get_doctor_category!(doctor_category.id) == doctor_category
    end

    test "create_doctor_category/1 with valid data creates a doctor_category" do
      valid_attrs = %{}

      assert {:ok, %DoctorCategory{} = doctor_category} = Categories.create_doctor_category(valid_attrs)
    end

    test "create_doctor_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Categories.create_doctor_category(@invalid_attrs)
    end

    test "update_doctor_category/2 with valid data updates the doctor_category" do
      doctor_category = doctor_category_fixture()
      update_attrs = %{}

      assert {:ok, %DoctorCategory{} = doctor_category} = Categories.update_doctor_category(doctor_category, update_attrs)
    end

    test "update_doctor_category/2 with invalid data returns error changeset" do
      doctor_category = doctor_category_fixture()
      assert {:error, %Ecto.Changeset{}} = Categories.update_doctor_category(doctor_category, @invalid_attrs)
      assert doctor_category == Categories.get_doctor_category!(doctor_category.id)
    end

    test "delete_doctor_category/1 deletes the doctor_category" do
      doctor_category = doctor_category_fixture()
      assert {:ok, %DoctorCategory{}} = Categories.delete_doctor_category(doctor_category)
      assert_raise Ecto.NoResultsError, fn -> Categories.get_doctor_category!(doctor_category.id) end
    end

    test "change_doctor_category/1 returns a doctor_category changeset" do
      doctor_category = doctor_category_fixture()
      assert %Ecto.Changeset{} = Categories.change_doctor_category(doctor_category)
    end
  end
end
