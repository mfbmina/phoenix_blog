defmodule BlogWeb.ErrorView do
  use BlogWeb, :view

  def render("error.json", %{message: message}) do
    %{message: message}
  end
end
