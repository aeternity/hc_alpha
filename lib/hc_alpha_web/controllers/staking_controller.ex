defmodule HcAlphaWeb.StakingController do
  use HcAlphaWeb, :controller

  def index(conn, _params) do
    node = HcAlpha.Node.url()
    wallet = Application.fetch_env!(:hc_alpha, :wallet_url)
    render(conn, "index.html", %{node: node, wallet: wallet})
  end
end
