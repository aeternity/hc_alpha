defmodule HcAlpha.ChainMonitor.PosValidators do
  use HcAlpha.ChainMonitor.Worker

  alias HcAlpha.Pos.Contract
  alias HcAlpha.Pos.Validators
  alias HcAlpha.Pos.Delegates

  @interval 15000

  def interval(), do: @interval

  def init(), do: %{validators: [], delegates: []}

  def refresh(_state) do
    validators =
      [:online_validators, :offline_validators]
      |> to_calldata()
      |> dry_run()
      |> parse_response([:online, :offline])
      |> to_validators()
      |> Validators.broadcast()

    delegates =
      validators
      |> to_state_calldata()
      |> dry_run()
      |> parse_response(validators)
      |> to_delegates()
      |> Delegates.broadcast()

    %{validators: validators, delegates: delegates}
  end

  defp to_calldata(list), do: Enum.map(list, &Contract.calldata/1)

  defp to_state_calldata(list),
    do: Enum.map(list, &Contract.calldata("get_validator_state", [&1.address]))

  defp dry_run(data), do: HcAlpha.Node.dry_run(Contract.id(), data)

  defp parse_response({:ok, results}, keys), do: Enum.zip(keys, results)

  defp to_validators(list) do
    Enum.flat_map(list, fn {status, %{height: height, value: validators}} ->
      for {address, stake} <- validators do
        balance =
          case HcAlpha.Node.account(address, height) do
            {:ok, %{"balance" => b}} -> b
            _ -> nil
          end

        Validators.create(address, height, status, stake, balance)
      end
    end)
  end

  defp to_delegates(list) do
    Enum.flat_map(list, fn {v, %{value: {_, stakers, total_shares}}} ->
      for {address, stake} <- stakers do
        %{
          address: address,
          validator: v.address,
          stake: stake,
          total_shares: total_shares
        }
      end
    end)
  end
end
