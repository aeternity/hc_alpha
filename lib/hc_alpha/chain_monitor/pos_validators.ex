defmodule HcAlpha.ChainMonitor.PosValidators do
  use HcAlpha.ChainMonitor.Worker

  alias HcAlpha.Pos.Contract
  alias HcAlpha.Pos.Validators

  @interval 15000

  def interval(), do: @interval

  def init(), do: %{}

  def refresh(state) do
    [:online_validators, :offline_validators]
    |> to_calldata()
    |> dry_run()
    |> parse_response([:online, :offline])
    |> to_maps()
    |> broadcast()

    state
  end

  defp to_maps({status, %{height: height, value: validators}}),
    do: Enum.map(validators, &to_map(&1, status, height))

  defp to_maps(list), do: Enum.flat_map(list, &to_maps/1)

  defp to_map({address, stake}, status, height) do
    balance =
      case HcAlpha.Node.account(address, height) do
        {:ok, %{"balance" => b}} -> b
        _ -> nil
      end

    Validators.create(address, height, status, stake, balance)
  end

  defp to_calldata(list), do: Enum.map(list, &Contract.calldata/1)

  defp dry_run(data), do: HcAlpha.Node.dry_run(Contract.id(), data)

  defp parse_response({:ok, results}, keys), do: Enum.zip(keys, results)

  defp broadcast(msg), do: Validators.broadcast(msg)
end
