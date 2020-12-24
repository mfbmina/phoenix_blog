defmodule BlogWeb.UserController do
  use BlogWeb, :controller

  alias Blog.Accounts
  alias Blog.Accounts.User
  alias Blog.Guardian

  action_fallback BlogWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, user_params) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render("jwt.json", jwt: token)
    end
  end

  def show(conn, %{"id" => id}) do
    case Accounts.get_user!(id) do
    nil ->
      {:error, :not_found, "Usuário não existe"}
    user ->
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, _params) do
    case Guardian.Plug.current_resource(conn) do
    nil ->
      {:error, :not_found, "Usuário não existe"}
    user ->
      with {:ok, %User{}} <- Accounts.delete_user(user) do
        send_resp(conn, :no_content, "")
      end
    end
  end

  def login(conn, %{"email" => "", "password" => _password}) do
    conn
    |> put_status(:bad_request)
    |> put_view(BlogWeb.ErrorView)
    |> render("error.json", message: "\"email\" is not allowed to be empty")
  end

  def login(conn, %{"email" => _email, "password" => ""}) do
    conn
    |> put_status(:bad_request)
    |> put_view(BlogWeb.ErrorView)
    |> render("error.json", message: "\"password\" is not allowed to be empty")
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.token_sign_in(email, password) do
      {:ok, token, _claims} ->
        conn |> render("jwt.json", jwt: token)
      _ ->
        conn
        |> put_status(:bad_request)
        |> put_view(BlogWeb.ErrorView)
        |> render("error.json", message: "Campos inválidos")
    end
  end

  def login(conn, %{"email" => _}) do
    conn
    |> put_status(:bad_request)
    |> put_view(BlogWeb.ErrorView)
    |> render("error.json", message: "\"password\" is required")
  end

  def login(conn, %{"password" => _}) do
    conn
    |> put_status(:bad_request)
    |> put_view(BlogWeb.ErrorView)
    |> render("error.json", message: "\"email\" is required")
  end
end
