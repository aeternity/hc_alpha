defmodule HcAlphaWeb.ValidatorsController do
  use HcAlphaWeb, :controller

  alias HcAlpha.Pos.Validators

  def index(conn, _params) do
    addresses = Validators.addresses()
    validators = for a <- addresses do
      {a, Validators.get_limited(a, 50)}
    end

    render(conn, "index.html", validators: validators)
  end
end
