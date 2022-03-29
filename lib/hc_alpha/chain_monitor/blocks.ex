defmodule HcAlpha.ChainMonitor.Blocks do
  use HcAlpha.ChainMonitor.Worker
  @interval 60000

  def interval(), do: @interval

  def init(), do: %{}

  defp refresh(state) do
    {:ok, %{"key_block" => block}} = HcAlpha.Node.current_generation()
    local_top_height = HcAlpha.Blocks.top_height()

    block
    |> traverse(local_top_height, [])
    |> HcAlpha.Blocks.insert_all!()
    |> HcAlpha.Blocks.broadcast()

    state
  end

  def traverse(%{"height" => local_height}, local_height, acc), do: acc

  def traverse(%{"height" => 0}, _, acc), do: acc

  def traverse(%{"prev_key_hash" => hash} = block, local_height, acc) do
    key_block = HcAlpha.Blocks.from_node_api(block)
    {:ok, %{"key_block" => next_block}} = HcAlpha.Node.generations_at_hash(hash)
    traverse(next_block, local_height, [key_block | acc])
  end
end
