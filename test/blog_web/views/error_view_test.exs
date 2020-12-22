defmodule BlogWeb.ErrorViewTest do
  use BlogWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders error.json" do
    assert render(BlogWeb.ErrorView, "error.json", %{message: "custom message"}) ==
             %{message: "custom message"}
  end
end
