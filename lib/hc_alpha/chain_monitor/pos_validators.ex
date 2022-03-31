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

  defp to_maps({status, validators}), do: Enum.map(validators, &to_map(&1, status))
  defp to_maps(list), do: Enum.flat_map(list, &to_maps/1)

  defp to_map({address, stake}, status), do: Validators.create(address, status, stake)

  defp to_calldata(list), do: Enum.map(list, &Contract.calldata/1)

  defp dry_run(data), do: HcAlpha.Node.dry_run(Contract.id(), data)

  defp parse_response({:ok, %{"results" => results}}, keys),
    do: Enum.zip_with(keys, results, &parse_result/2)

  defp parse_result(key, %{"result" => "ok", "call_obj" => %{"return_value" => value}}) do
    {key, Contract.return_value(value)}
  end

  defp broadcast(msg), do: Validators.broadcast(msg)
end
