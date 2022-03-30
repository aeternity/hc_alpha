defmodule HcAlpha.ChainMonitor.PosValidators do
  use HcAlpha.ChainMonitor.Worker

  alias HcAlpha.Pos.Validators

  @interval 15000
  @contract "ct_LRbi65kmLtE7YMkG6mvG5TxAXTsPJDZjAtsPuaXtRyPA7gnfJ"

  def interval(), do: @interval

  def init(), do: %{}

  def refresh(state) do
    [:online, :offline]
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

  defp to_calldata(:online), do: "cb_KxEPwcyaP6jiGWM="
  defp to_calldata(:offline), do: "cb_KxGXKJ9hP2avNO8="
  defp to_calldata(list), do: Enum.map(list, &to_calldata/1)

  defp dry_run(data), do: HcAlpha.Node.dry_run(@contract, data)

  defp parse_response({:ok, %{"results" => results}}, keys),
    do: Enum.zip_with(keys, results, &parse_result/2)

  defp parse_result(key, %{"result" => "ok", "call_obj" => %{"return_value" => value}}) do
    value =
      :contract_bytearray
      |> :aeser_api_encoder.safe_decode(value)
      |> elem(1)
      |> :aeb_fate_encoding.deserialize()
      |> parse_value()

    {key, value}
  end

  defp parse_value(list) when is_list(list), do: Enum.map(list, &parse_value/1)
  defp parse_value({:tuple, {v1, v2}}), do: {parse_value(v1), parse_value(v2)}
  defp parse_value({:address, value}), do: :aeser_api_encoder.encode(:account_pubkey, value)
  defp parse_value(other), do: other

  defp broadcast(msg), do: Validators.broadcast(msg)
end
