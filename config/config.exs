# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :hc_alpha,
  ecto_repos: [HcAlpha.Repo],
  # node_url: "http://localhost:3013",
  # node_url: "http://3.105.185.75:3013"
  node_url: "http://13.239.157.207:3013",
  contract_id: "ct_LRbi65kmLtE7YMkG6mvG5TxAXTsPJDZjAtsPuaXtRyPA7gnfJ",
  contract_name: "MainStaking.aes"

# Configures the endpoint
config :hc_alpha, HcAlphaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: HcAlphaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: HcAlpha.PubSub,
  live_view: [signing_salt: "wiBreoT/"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :hc_alpha, HcAlpha.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
