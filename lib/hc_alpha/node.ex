defmodule HcAlpha.Node do
  @moduledoc """
  API for talking directly to an aeternity node
  """

  alias HcAlpha.Node.Api

  def status(), do: Api.get("v2/status")

  def current_generation(), do: Api.get("v2/generations/current")

  def generations_at_hash(hash), do: Api.get("v2/generations/hash/" <> hash)

  def dry_run(contract, list) when is_list(list) do
    txs =
      Enum.map(list, fn calldata ->
        %{
          "call_req" => %{
            "abi_version" => 3,
            "amount" => 0,
            "calldata" => calldata,
            "contract" => contract,
            "gas" => 1_000_00
          }
        }
      end)

    Api.post("v3/dry-run", %{"txs" => txs})
  end

  def dry_run(contract, calldata), do: dry_run(contract, [calldata])
end
