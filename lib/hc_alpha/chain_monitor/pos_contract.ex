defmodule HcAlpha.ChainMonitor.PosContract do
  @interval 15000
  @contract "ct_LRbi65kmLtE7YMkG6mvG5TxAXTsPJDZjAtsPuaXtRyPA7gnfJ"
  @validator1 "ak_2MGLPW2CHTDXJhqFJezqSwYSNwbZokSKkG7wSbGtVmeyjGfHtm"
  @validator2 "ak_nQpnNuBPQwibGpSJmjAah6r3ktAB7pG9JHuaGWHgLKxaKqEvC"
  @validator3 "ak_LRbi65kmLtE7YMkG6mvG5TxAXTsPJDZjAtsPuaXtRyPA7gnfJ"

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :transient
    }
  end

  def init(_) do
    send(self(), :refresh)
    {:ok, %{}}
  end

  def handle_call(_, _from, state), do: {:reply, :ok, state}

  def handle_info(:refresh, _state) do
    state = refresh_data()
    refresh_timer()
    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}

  defp refresh_timer() do
    interval = @interval
    Process.send_after(self(), :refresh, interval)
  end

  defp refresh_data() do
    call(:leader)
    call(:elect_next)

    # , {:balance, @validator3}]
    [{:balance, @validator1}, {:balance, @validator2}]
    |> Enum.map(fn key -> call(key) end)
    |> HcAlpha.Pos.broadcast_balances()
  end

  defp call(key) do
    calldata = calldata(key)

    @contract
    |> HcAlpha.Node.dry_run(calldata)
    |> return_value()
    |> parse_return_value(key)
  end

  defp return_value({:ok, %{"results" => [%{"call_obj" => %{"return_value" => value}}]}}),
    do: value

  defp parse_return_value(value, {:balance, account}) do
    {:ok, value_bin} = :aeser_api_encoder.safe_decode(:contract_bytearray, value)
    balance = :aeb_fate_encoding.deserialize(value_bin)

    account
    |> HcAlpha.Pos.balance_from_node_api(balance)
    |> HcAlpha.Pos.insert()
  end

  defp parse_return_value(value, :leader),
    do: value |> to_address |> HcAlpha.Pos.broadcast_current_leader()

  defp parse_return_value(value, :elect_next),
    do: value |> to_address |> HcAlpha.Pos.broadcast_next_leader()

  defp calldata(:leader), do: "cb_KxGkPMxUP7a3L/k="
  defp calldata(:elect_next), do: "cb_KxFodeDRP1Jz2f0="

  defp calldata({:balance, @validator1}),
    do: "cb_KxG0jBaEG58AoLG1d7zTJ8s55V5sAmvWp0obNd5sBlDErlHvq3WeQVtmQlLizQ=="

  defp calldata({:balance, @validator2}),
    do: "cb_KxG0jBaEG58AoGccVUZGSUV1srSU9lFoIXEGY9hIk83S0jYDelTDPu6EqfRW3w=="

  defp calldata({:balance, @validator3}),
    do: "cb_KxG0jBaEG58AoCwa1XR0IGCPLLSke5feeoiyjmk1qS7sGM/WHuFMzrFoNiyv3w=="

  defp to_address("cb_nwCgsbV3vNMnyznlXmwCa9anShs13mwGUMSuUe+rdZ5BW2bDvnY6"), do: @validator1
  defp to_address("cb_nwCgZxxVRkZJRXWytJT2UWghcQZj2EiTzdLSNgN6VMM+7oRJmcE0"), do: @validator2
  defp to_address("cb_nwCgLBrVdHQgYI8stKR7l956iLKOaTWpLuwYz9Ye4UzOsWhuxaJQ"), do: @validator3
end
