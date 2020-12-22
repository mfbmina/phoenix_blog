defmodule Blog.PostsTest do
  use Blog.DataCase

  alias Blog.Accounts
  alias Blog.Posts

  describe "posts" do
    alias Blog.Posts.Post

    @valid_attrs %{content: "some content", title: "some title"}
    @update_attrs %{content: "some updated content", title: "some updated title"}
    @invalid_attrs %{content: nil, title: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(%{email: "some@email.com", password: "some password_hash", display_name: "Foo Barr"})
        |> Accounts.create_user()

      user
    end

    def post_fixture() do
      user = user_fixture()
      attrs = Map.merge(@valid_attrs, %{user_id: user.id})

      {:ok, post} = Posts.create_post(attrs)

      post
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()

      assert Posts.list_posts() == [Repo.preload(post, :user)]
    end

    test "list_posts/1 returns posts which match" do
      post = post_fixture()

      assert Posts.list_posts("some") == [Repo.preload(post, :user)]
      assert Posts.list_posts("random") == []
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post!(post.id) == Repo.preload(post, :user)
    end

    test "create_post/1 with valid data creates a post" do
      user = user_fixture()
      attrs = Map.merge(@valid_attrs, %{user_id: user.id})

      assert {:ok, %Post{} = post} = Posts.create_post(attrs)
      assert post.content == "some content"
      assert post.title == "some title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, %Post{} = post} = Posts.update_post(post, @update_attrs)
      assert post.content == "some updated content"
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert Repo.preload(post, :user) == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end
end
