defmodule HcAlpha.ChainMonitor.Blocks do
  @interval 30000

  # def init(), do: send(__MODULE__, :init)

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
    {:ok, %{"key_block" => block}} = HcAlpha.Node.current_generation()
    local_top_height = HcAlpha.Blocks.top_height()

    block
    |> traverse(local_top_height, [])
    |> HcAlpha.Blocks.insert_all!()
    |> HcAlpha.Blocks.broadcast()
  end

  def traverse(%{"height" => local_height}, local_height, acc), do: acc

  def traverse(%{"height" => 0}, _, acc), do: acc

  def traverse(%{"prev_key_hash" => hash} = block, local_height, acc) do
    key_block = HcAlpha.Blocks.from_node_api(block)
    {:ok, %{"key_block" => next_block}} = HcAlpha.Node.generations_at_hash(hash)
    traverse(next_block, local_height, [key_block | acc])
  end
end
