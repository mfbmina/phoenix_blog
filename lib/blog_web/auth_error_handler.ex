defmodule Blog.AuthErrorHandler do
  @moduledoc false

  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    message = case type do
    :invalid_token ->
      "Token expirado ou inválido"
    :unauthenticated ->
      "Token não encontrado"
    end

    body = Jason.encode!(%{message: message})

    conn
    |> put_resp_content_type("application/json; charset=utf-8")
    |> send_resp(:unauthorized, body)
  end
end
