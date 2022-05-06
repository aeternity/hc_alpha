defmodule HcAlphaWeb.StakingController do
  use HcAlphaWeb, :controller

  def index(conn, _params) do
    node = HcAlpha.Node.url()
    wallet = Application.fetch_env!(:hc_alpha, :wallet_url)
    faucet = Application.fetch_env!(:hc_alpha, :faucet_url)
    render(conn, "index.html", %{node: node, wallet: wallet, faucet: faucet})
  end
end
