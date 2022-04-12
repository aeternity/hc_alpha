defmodule HcAlphaWeb.StakingController do
  use HcAlphaWeb, :controller

  def index(conn, _params) do
    node = HcAlpha.Node.url()
    render(conn, "index.html", %{node: node})
  end
end
