defmodule HcAlpha.Pos do
  @moduledoc """
  """

  import Ecto.Query
  alias HcAlpha.Repo
  alias Ecto.Changeset

  alias HcAlpha.Pos.Balance

  def subscribe(:leaders), do: Phoenix.PubSub.subscribe(HcAlpha.PubSub, "leaders")
  def subscribe(:balances), do: Phoenix.PubSub.subscribe(HcAlpha.PubSub, "balances")

  def broadcast(:balances, msg), do: broadcast_internal("balances", {:balances, msg})
  def broadcast(:elect_next, msg), do: broadcast_internal("leaders", {:next_leader, msg})
  def broadcast(:leader, msg), do: broadcast_internal("leaders", {:current_leader, msg})

  defp broadcast_internal(topic, msg), do: Phoenix.PubSub.broadcast(HcAlpha.PubSub, topic, msg)

  def balance_from_node_api(account, balance) do
    attrs = %{
      account: account,
      balance: aetto_to_ae(balance)
    }

    %Balance{}
    |> Balance.changeset(attrs)
    |> Changeset.apply_changes()
  end

  def balances() do
    Repo.all(from b in Balance, order_by: b.balance)
  end

  def insert(%Balance{} = balance),
    do:
      Repo.insert!(balance,
        on_conflict: [set: [balance: balance.balance]],
        conflict_target: :account
      )

  defp aetto_to_ae(aetto), do: aetto / :math.pow(10, 18)
end
