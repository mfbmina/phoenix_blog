defmodule BlogWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use BlogWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{errors: [email: {_, [constraint: :unique, constraint_name: _]}]}}) do
    conn
    |> put_status(:conflict)
    |> put_view(BlogWeb.ErrorView)
    |> render("error.json", message: "Usuário já existe")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:bad_request)
    |> put_view(BlogWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found, message}) do
    conn
    |> put_status(:not_found)
    |> put_view(BlogWeb.ErrorView)
    |> render("error.json", message: message)
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(BlogWeb.ErrorView)
    |> render("error.json", message: "Usuário não autorizado")
  end
end
