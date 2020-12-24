defmodule BlogWeb.Router do
  use BlogWeb, :router
  use Plug.ErrorHandler

  pipeline :api do
    plug :accepts, ["json"]
    plug ProperCase.Plug.SnakeCaseParams
  end

  pipeline :authenticated do
    plug Blog.Guardian.AuthPipeline
  end

  scope "/", BlogWeb do
    pipe_through :api

    post "/login", UserController, :login
    post "/user", UserController, :create
  end

  scope "/", BlogWeb do
    pipe_through [:api, :authenticated]

    delete "/users/me", UserController, :delete
    get "/posts/search", PostController, :search

    resources "/users", UserController, only: [:index, :show]
    resources "/posts", PostController
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: BlogWeb.Telemetry
    end
  end

  def handle_errors(conn, %{kind: kind, reason: reason, stack: _stack}) do
    body = Jason.encode!(%{message: "Something went wrong", details: reason.message})

    conn
    |> put_resp_content_type("application/json; charset=utf-8")
    |> send_resp(:internal_server_error, body)
  end
end
