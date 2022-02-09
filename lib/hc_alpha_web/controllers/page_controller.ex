defmodule HcAlphaWeb.PageController do
  use HcAlphaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
