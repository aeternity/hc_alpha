defmodule HcAlpha.Pos.Validators do
  import Ecto.Query
  alias HcAlpha.Repo

  alias HcAlpha.Pos
  alias HcAlpha.Pos.Validator

  @pubsub "validators"

  def subscribe(), do: Pos.subscribe(@pubsub)

  def broadcast(msg), do: Pos.broadcast(@pubsub, {:validators, msg})

  def create(address, height, status, stake, balance) do
    attrs = %{
      address: address,
      height: height,
      status: status,
      stake: aetto_to_ae(stake),
      balance: aetto_to_ae(balance)
    }

    %Validator{}
    |> Validator.changeset(attrs)
    |> Repo.insert!(
      on_conflict: [set: [stake: attrs.stake, balance: attrs.balance]],
      conflict_target: [:address, :height]
    )
  end

  def list_top() do
    Repo.all(
      from v in Validator,
        distinct: v.address,
        order_by: [v.address, desc: v.height],
        select: v
    )
  end

  def addresses() do
    Repo.all(from v in Validator,
      distinct: v.address,
      select: v.address
    )
  end

  def get_limited(address, limit) do
    Repo.all(from v in Validator,
      where: v.address == ^address,
      order_by: [desc: v.height],
      select: v,
      limit: ^limit
    )
  end

  defp aetto_to_ae(aetto), do: aetto / :math.pow(10, 18)
end
