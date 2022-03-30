defmodule HcAlpha.ChainMonitor.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      HcAlpha.ChainMonitor.Status,
      HcAlpha.ChainMonitor.Blocks,
      HcAlpha.ChainMonitor.PosLeaders,
      HcAlpha.ChainMonitor.PosValidators
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
