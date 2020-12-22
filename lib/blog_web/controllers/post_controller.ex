defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  alias Blog.Posts
  alias Blog.Posts.Post

  action_fallback BlogWeb.FallbackController

  def index(conn, _params) do
    posts = Posts.list_posts()
    render(conn, "index.json", posts: posts)
  end

  def create(conn, %{"title" => title, "content" => content}) do
    {:ok, user} = current_user(conn)
    post_params = %{"title" => title, "content" => content, "user_id" => user.id}

    with {:ok, %Post{} = post} <- Posts.create_post(post_params) do
      conn
      |> put_status(:created)
      |> render("create.json", post: post)
    end
  end

  def show(conn, %{"id" => id}) do
    case Posts.get_post!(id) do
    nil ->
      {:error, :not_found, "Post não existe"}
    post ->
      render(conn, "show.json", post: post)
    end
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)

    with {:ok, %Post{} = post} <- Posts.update_post(post, post_params) do
      render(conn, "show.json", post: post)
    end
  end

  def delete(conn, %{"id" => id}) do
    case Posts.get_post!(id) do
    nil ->
      {:error, :not_found, "Post não existe"}
    post ->
      with {:ok, %Post{}} <- Posts.delete_post(post) do
        send_resp(conn, :no_content, "")
      end
    end
  end

  defp current_user(conn) do
    case Guardian.Plug.current_resource(conn) do
    nil ->
      {:error, :not_found, "Usuário não existe"}
    user ->
      {:ok, user}
    end
  end
end
