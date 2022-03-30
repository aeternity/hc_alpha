defmodule HcAlpha.Pos.Validators do
  import Ecto.Query
  alias HcAlpha.Repo

  alias HcAlpha.Pos
  alias HcAlpha.Pos.Validator

  @pubsub "validators"

  def subscribe(), do: Pos.subscribe(@pubsub)

  def broadcast(msg), do: Pos.broadcast(@pubsub, {:validators, msg})

  def create(address, status, stake) do
    attrs = %{
      address: address,
      status: status,
      stake: aetto_to_ae(stake)
    }

    %Validator{}
    |> Validator.changeset(attrs)
    |> Repo.insert!(
      on_conflict: [set: [stake: attrs.stake]],
      conflict_target: :address
    )
  end

  def list() do
    Repo.all(from b in Validator, order_by: b.stake)
  end

  defp aetto_to_ae(aetto), do: aetto / :math.pow(10, 18)
end
