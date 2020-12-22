defmodule Blog.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :blog, module: Blog.Guardian, error_handler: Blog.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
