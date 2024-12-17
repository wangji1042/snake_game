defmodule SnakeGameWeb.PageController do
  use SnakeGameWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def index(conn, _params) do
    render(conn, :home, layout: false)
  end
end
