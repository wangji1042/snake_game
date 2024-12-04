# lib/snake_game_web/controllers/redirect_controller.ex
defmodule SnakeGameWeb.RedirectController do
  use SnakeGameWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/game")
  end
end
