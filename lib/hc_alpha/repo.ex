defmodule HcAlpha.Repo do
  use Ecto.Repo,
    otp_app: :hc_alpha,
    adapter: Ecto.Adapters.Postgres
end
