defmodule BlogWeb.PostControllerTest do
  use BlogWeb.ConnCase

  alias Blog.Accounts
  alias Blog.Guardian
  alias Blog.Posts

  @create_attrs %{
    content: "some content",
    title: "some title"
  }
  @update_attrs %{
    content: "some updated content",
    title: "some updated title"
  }
  @invalid_attrs %{content: nil, title: nil}

  def fixture(:post, user_id) do
    attrs = Map.merge(@create_attrs, %{user_id: user_id})
    {:ok, post} = Posts.create_post(attrs)
    post
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:valid_token, :create_post]

    test "lists all posts", %{conn: conn, post: post, user: user} do
      conn = get(conn, Routes.post_path(conn, :index))
      assert json_response(conn, 200) == [%{
        "id" => post.id,
        "title" => post.title,
        "content" => post.content,
        "published" => NaiveDateTime.to_iso8601(post.inserted_at),
        "updated" => NaiveDateTime.to_iso8601(post.updated_at),
        "user" => %{
          "display_name" => user.display_name,
          "email" => user.email,
          "id" => user.id,
          "image" => user.image }
        }
      ]
    end
  end

  describe "index with invalid token" do
    setup %{conn: conn} do
      new_conn = conn |> put_req_header("authorization", "Bearer wrong_token")

      {:ok, conn: new_conn}
    end

    test "renders post when data is valid", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :index))
      assert json_response(conn, 401)["message"] == "Token expirado ou inválido"
    end
  end

  describe "index without token" do
    test "renders post when data is valid", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :index))
      assert json_response(conn, 401)["message"] == "Token não encontrado"
    end
  end

  describe "show with valid id" do
    setup [:valid_token, :create_post]

    test "lists all posts", %{conn: conn, post: post, user: user} do
      conn = get(conn, Routes.post_path(conn, :show, post))
      assert json_response(conn, 200) == %{
        "id" => post.id,
        "title" => post.title,
        "content" => post.content,
        "published" => NaiveDateTime.to_iso8601(post.inserted_at),
        "updated" => NaiveDateTime.to_iso8601(post.updated_at),
        "user" => %{
          "display_name" => user.display_name,
          "email" => user.email,
          "id" => user.id,
          "image" => user.image }
        }
    end
  end

  describe "show with invalid id" do
    setup [:valid_token]

    test "lists all posts", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :show, 999_999))
      assert json_response(conn, 404)["message"] == "Post não existe"
    end
  end

  describe "show with invalid token" do
    setup %{conn: conn} do
      new_conn = conn |> put_req_header("authorization", "Bearer wrong_token")

      {:ok, conn: new_conn}
    end

    test "renders post when data is valid", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :show, 999_999))
      assert json_response(conn, 401)["message"] == "Token expirado ou inválido"
    end
  end

  describe "show without token" do
    test "renders post when data is valid", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :show, 999_999))
      assert json_response(conn, 401)["message"] == "Token não encontrado"
    end
  end

  describe "create post" do
    setup [:valid_token]

    test "renders post when data is valid", %{conn: conn, user: user} do
      conn = post(conn, Routes.post_path(conn, :create), @create_attrs)
      assert json_response(conn, 201)["user_id"] == user.id
      assert json_response(conn, 201)["title"] == "some title"
      assert json_response(conn, 201)["content"] == "some content"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), @invalid_attrs)
      assert json_response(conn, 400)["errors"] != %{}
    end
  end

  describe "create post with invalid token" do
    setup %{conn: conn} do
      new_conn = conn |> put_req_header("authorization", "Bearer wrong_token")

      {:ok, conn: new_conn}
    end

    test "renders post when data is valid", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), @create_attrs)
      assert json_response(conn, 401)["message"] == "Token expirado ou inválido"
    end
  end

  describe "create post without token" do
    test "renders post when data is valid", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), @create_attrs)
      assert json_response(conn, 401)["message"] == "Token não encontrado"
    end
  end

  describe "update post" do
    setup [:valid_token, :create_post]

    test "renders post when data is valid", %{conn: conn, post: post, user: user} do
      attrs = Map.merge(@update_attrs, %{user_id: user.id})
      conn = put(conn, Routes.post_path(conn, :update, post), post: attrs)

      assert json_response(conn, 200)["title"] == @update_attrs[:title]
      assert json_response(conn, 200)["content"] == @update_attrs[:content]
    end

    test "renders errors when data is invalid", %{conn: conn, post: post} do
      conn = put(conn, Routes.post_path(conn, :update, post), post: @invalid_attrs)
      assert json_response(conn, 400)["errors"] != %{}
    end
  end

  describe "delete post" do
    setup [:valid_token, :create_post]

    test "deletes chosen post", %{conn: conn, post: post} do
      conn = delete(conn, Routes.post_path(conn, :delete, post))
      assert response(conn, 204)

      conn = get(conn, Routes.post_path(conn, :show, post.id))
      assert json_response(conn, 404)["message"] == "Post não existe"
    end
  end

  defp create_post(%{user: user}) do
    post = fixture(:post, user.id)
    %{post: post}
  end

  defp valid_token(%{conn: conn}) do
    {:ok, user} = Accounts.create_user(%{email: "some@some.com", password: "123456", display_name: "Foo Barr"})
    {:ok, jwt, _claims} = Guardian.encode_and_sign(user)
    new_conn = conn |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, conn: new_conn, user: user}
  end
end
