defmodule BlogWeb.UserControllerTest do
  use BlogWeb.ConnCase

  alias Blog.Accounts
  alias Blog.Guardian

  @create_attrs %{email: "some@email.com", password: "some password_hash", display_name: "Foo Barr"}
  # @update_attrs %{
  #   email: "some updated email",
  #   password_hash: "some updated password_hash"
  # }
  @invalid_attrs %{email: nil, password_hash: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index without token" do
    test "returns an error message", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 401)["message"] == "Token não encontrado"
    end
  end

  describe "index with valid token" do
    setup [:valid_token]

    test "lists all users", %{conn: conn, auth_user: user} do
      conn = get(conn, Routes.user_path(conn, :index))

      assert json_response(conn, 200) == [%{"display_name" => user.display_name, "email" => user.email, "id" => user.id, "image" => user.image}]
    end
  end

  describe "index with invalid token" do
    setup %{conn: conn} do
      new_conn = conn |> put_req_header("authorization", "Bearer wrong_token")

      {:ok, conn: new_conn}
    end

    test "return an error message", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 401)["message"] == "Token expirado ou inválido"
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"jwt" => _jwt} = json_response(conn, 201)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when email is duplicated", %{conn: conn} do
      create_user(nil)
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert json_response(conn, 409)["errors"] != %{}
    end
  end

  describe "login user" do
    setup [:create_user]

    test "renders jwt when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :login), email: "some@email.com", password: "some password_hash")
      assert %{"jwt" => _jwt} = json_response(conn, 200)
    end

    test "renders errors when password is incorrect", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :login), email: "some@email.com", password: "password_hash")
      assert json_response(conn, 400)["message"] == "Campos inválidos"
    end

    test "renders errors when email is incorrect", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :login), email: "some@some.com", password: "password_hash")
      assert json_response(conn, 400)["message"] == "Campos inválidos"
    end

    test "renders errors when password is empty", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :login), email: "some@email.com", password: "")
      assert json_response(conn, 400)["message"] == "\"password\" is not allowed to be empty"
    end

    test "renders errors when email is empty", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :login), email: "", password: "password_hash")
      assert json_response(conn, 400)["message"] == "\"email\" is not allowed to be empty"
    end

    test "renders errors when password is nil", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :login), email: "some@email.com")
      assert json_response(conn, 400)["message"] == "\"password\" is required"
    end

    test "renders errors when email is nil", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :login), password: "password_hash")
      assert json_response(conn, 400)["message"] == "\"email\" is required"
    end
  end

  # describe "update user" do
  #   setup [:create_user]
  #
  #   test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
  #     conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]
  #
  #     conn = get(conn, Routes.user_path(conn, :show, id))
  #
  #     assert %{
  #              "id" => id,
  #              "email" => "some updated email",
  #              "password_hash" => "some updated password_hash"
  #            } = json_response(conn, 200)["data"]
  #   end
  #
  #   test "renders errors when data is invalid", %{conn: conn, user: user} do
  #     conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end
  #
  # describe "delete user" do
  #   setup [:create_user]
  #
  #   test "deletes chosen user", %{conn: conn, user: user} do
  #     conn = delete(conn, Routes.user_path(conn, :delete, user))
  #     assert response(conn, 204)
  #
  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.user_path(conn, :show, user))
  #     end
  #   end
  # end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end

  defp valid_token(%{conn: conn}) do
    {:ok, user} = Accounts.create_user(%{email: "some@some.com", password: "123456", display_name: "Foo Barr"})
    {:ok, jwt, _claims} = Guardian.encode_and_sign(user)
    new_conn = conn |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, conn: new_conn, auth_user: user}
  end
end
