defmodule HcAlpha.ChainMonitor.PosLeaders do
  use HcAlpha.ChainMonitor.Worker

  @interval 15000
  @contract "ct_LRbi65kmLtE7YMkG6mvG5TxAXTsPJDZjAtsPuaXtRyPA7gnfJ"
  @validator1 "ak_2MGLPW2CHTDXJhqFJezqSwYSNwbZokSKkG7wSbGtVmeyjGfHtm"
  @validator2 "ak_nQpnNuBPQwibGpSJmjAah6r3ktAB7pG9JHuaGWHgLKxaKqEvC"
  @validator3 "ak_LRbi65kmLtE7YMkG6mvG5TxAXTsPJDZjAtsPuaXtRyPA7gnfJ"

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

  defp to_calldata(:leader), do: "cb_KxGkPMxUP7a3L/k="
  defp to_calldata(:elect_next), do: "cb_KxFodeDRP1Jz2f0="
  defp to_calldata(list), do: Enum.map(list, &to_calldata/1)

  defp dry_run(data), do: HcAlpha.Node.dry_run(@contract, data)

  defp parse_response({:ok, %{"results" => results}}, keys),
    do: Enum.zip_with(keys, results, &parse_result/2)

  defp parse_result(key, %{"result" => "ok", "call_obj" => %{"return_value" => value}}),
    do: {key, to_address(value)}

  defp to_address("cb_nwCgsbV3vNMnyznlXmwCa9anShs13mwGUMSuUe+rdZ5BW2bDvnY6"), do: @validator1
  defp to_address("cb_nwCgZxxVRkZJRXWytJT2UWghcQZj2EiTzdLSNgN6VMM+7oRJmcE0"), do: @validator2
  defp to_address("cb_nwCgLBrVdHQgYI8stKR7l956iLKOaTWpLuwYz9Ye4UzOsWhuxaJQ"), do: @validator3

  defp broadcast({key, msg}) do
    HcAlpha.Pos.broadcast(key, msg)
    {key, msg}
  end

  defp broadcast(list), do: Enum.map(list, &broadcast/1)
end