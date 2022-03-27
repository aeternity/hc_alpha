defmodule HcAlpha.Blocks do
  @moduledoc """
  """

  import Ecto.Query

  alias HcAlpha.Repo
  alias Ecto.Changeset

  alias HcAlpha.Blocks.KeyBlock

  def subscribe(), do: Phoenix.PubSub.subscribe(HcAlpha.PubSub, "key_blocks")

  def broadcast(blocks),
    do: Phoenix.PubSub.broadcast(HcAlpha.PubSub, "key_blocks", {:key_blocks, blocks})

  def from_node_api(raw) do
    attrs = %{
      hash: raw["hash"],
      prev_hash: raw["prev_key_hash"],
      height: raw["height"],
      beneficiary: raw["beneficiary"],
      validator: raw["miner"]
    }

    %KeyBlock{}
    |> KeyBlock.changeset(attrs)
    |> Changeset.apply_changes()
  end

  def insert!(%KeyBlock{} = block), do: Repo.insert!(block)

  def insert_all!(blocks) do
    Enum.map(blocks, fn block -> insert!(block) end)
  end

  def top_height() do
    case Repo.one(from kb in KeyBlock, select: max(kb.height)) do
      nil -> 0
      height -> height
    end
  end

  def distribution() do
    Repo.all(
      from kb in KeyBlock,
        group_by: kb.validator,
        select: %{address: kb.validator, count: count(kb)}
    )
  end

  def list(limit) do
    Repo.all(
      from kb in KeyBlock,
        select: kb,
        order_by: [desc: kb.height],
        limit: ^limit
    )
  end
end
