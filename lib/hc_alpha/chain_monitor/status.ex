defmodule HcAlpha.ChainMonitor.Status do
  use HcAlpha.ChainMonitor.Worker
  @interval 1000

  def interval(), do: @interval

  def init(), do: %{}

  def refresh(_state) do
    {:ok, r} = HcAlpha.Node.status()
    r
  end
end
