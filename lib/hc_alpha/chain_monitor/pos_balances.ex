defmodule HcAlpha.ChainMonitor.PosBalances do
  use HcAlpha.ChainMonitor.Worker

  @interval 15000
  @contract "ct_LRbi65kmLtE7YMkG6mvG5TxAXTsPJDZjAtsPuaXtRyPA7gnfJ"

  @validator1 "ak_2MGLPW2CHTDXJhqFJezqSwYSNwbZokSKkG7wSbGtVmeyjGfHtm"
  @validator2 "ak_nQpnNuBPQwibGpSJmjAah6r3ktAB7pG9JHuaGWHgLKxaKqEvC"
  @validator3 "ak_LRbi65kmLtE7YMkG6mvG5TxAXTsPJDZjAtsPuaXtRyPA7gnfJ"

  @calldata1 "cb_KxG0jBaEG58AoLG1d7zTJ8s55V5sAmvWp0obNd5sBlDErlHvq3WeQVtmQlLizQ=="
  @calldata2 "cb_KxG0jBaEG58AoGccVUZGSUV1srSU9lFoIXEGY9hIk83S0jYDelTDPu6EqfRW3w=="
  @calldata3 "cb_KxG0jBaEG58AoCwa1XR0IGCPLLSke5feeoiyjmk1qS7sGM/WHuFMzrFoNiyv3w=="

  def interval(), do: @interval

  def init(), do: %{}

  def refresh(state) do
    keys = [@validator1, @validator2]

    keys
    |> to_calldata()
    |> dry_run()
    |> parse_response(keys)
    |> broadcast()

    state
  end

  defp to_calldata(@validator1), do: @calldata1
  defp to_calldata(@validator2), do: @calldata2
  defp to_calldata(@validator3), do: @calldata3
  defp to_calldata(list), do: Enum.map(list, &to_calldata/1)

  defp dry_run(data), do: HcAlpha.Node.dry_run(@contract, data)

  defp parse_response({:ok, %{"results" => results}}, keys),
    do: Enum.zip_with(keys, results, &parse_result/2)

  defp parse_result(account, %{"result" => "ok", "call_obj" => %{"return_value" => value}}) do
    {:ok, value_bin} = :aeser_api_encoder.safe_decode(:contract_bytearray, value)
    balance = :aeb_fate_encoding.deserialize(value_bin)

    account
    |> HcAlpha.Pos.balance_from_node_api(balance)
    |> HcAlpha.Pos.insert()
  end

  defp broadcast(msg), do: HcAlpha.Pos.broadcast(:balances, msg)
end
