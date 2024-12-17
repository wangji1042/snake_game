defmodule SnakeGameWeb.GameController do
  use SnakeGameWeb, :controller

  def index(conn, _params) do
    render_static_file(conn, "index.html")
  end

  defp render_static_file(conn, file) do
    conn
    |> put_resp_content_type("text/html")
    |> Plug.Conn.send_file(200, Path.join(:code.priv_dir(:snake_game), "static/#{file}"))
  end
end
