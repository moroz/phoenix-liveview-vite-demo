defmodule TanokiWeb.PageController do
  use TanokiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
