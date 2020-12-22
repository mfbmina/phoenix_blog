defmodule Blog.AccountsTest do
  use Blog.DataCase

  alias Blog.Accounts

  describe "users" do
    alias Blog.Accounts.User

    @valid_attrs %{email: "some@email.com", password: "some password_hash", display_name: "Foo Barr"}
    @invalid_attrs %{email: nil, password_hash: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      [stored_user | []] = Accounts.list_users()

      assert stored_user.email == user.email
      assert stored_user.display_name == user.display_name
      assert stored_user.image == user.image
      assert stored_user.password_hash == user.password_hash
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      stored_user = Accounts.get_user!(user.id)
      assert stored_user.email == user.email
      assert stored_user.display_name == user.display_name
      assert stored_user.image == user.image
      assert stored_user.password_hash == user.password_hash
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some@email.com"
      assert user.display_name == "Foo Barr"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert Accounts.get_user!(user.id) == nil
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
