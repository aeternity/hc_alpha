defmodule HcAlpha.ChainMonitor.PosLeaders do
  use HcAlpha.ChainMonitor.Worker

  alias HcAlpha.Pos.Contract

  @interval 15000

  def interval(), do: @interval

  def init(), do: %{}

  def refresh(_state) do
    keys = [:leader, :elect_next]

    keys
    |> to_calldata()
    |> dry_run()
    |> parse_response(keys)
    |> broadcast()
    |> Enum.into(%{})
  end

  defp to_calldata(list), do: Enum.map(list, &Contract.calldata/1)

  defp dry_run(data), do: HcAlpha.Node.dry_run(Contract.id(), data)

  defp parse_response({:ok, results}, keys), do: Enum.zip(keys, results)

  defp broadcast({key, msg}) do
    HcAlpha.Pos.broadcast(key, msg)
    {key, msg}
  end

  defp broadcast(list), do: Enum.map(list, &broadcast/1)
end
