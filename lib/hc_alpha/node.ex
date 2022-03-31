defmodule HcAlpha.Node do
  @moduledoc """
  API for talking directly to an aeternity node
  """

  alias HcAlpha.Node.Api

  def status(), do: Api.get("v2/status")

  def current_generation(), do: Api.get("v2/generations/current")

  def generations_at_hash(hash), do: Api.get("v2/generations/hash/" <> hash)

  def account(hash, height),
    do: Api.get("v2/accounts/" <> hash <> "/height/" <> Integer.to_string(height))

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

    "v3/dry-run"
    |> Api.post(%{"txs" => txs})
    |> dry_run_response()
  end

  def dry_run(contract, calldata), do: dry_run(contract, [calldata])

  defp dry_run_response({:ok, %{"results" => results}}) do
    {:ok, Enum.map(results, &dry_run_result/1)}
  end

  defp dry_run_result(%{"call_obj" => %{"height" => height, "return_value" => value}}) do
    %{
      height: height,
      value: HcAlpha.Pos.Contract.return_value(value)
    }
  end
end
