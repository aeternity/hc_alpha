defmodule HcAlpha.ChainMonitor.Status do
  @interval 10000

  def state(), do: GenServer.call(__MODULE__, :state)

  def start(), do: GenServer.call(__MODULE__, :refresh)

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
    send(self(), :init)
    {:ok, %{}}
  end

  def handle_call(:state, _from, state), do: {:reply, state, state}

  def handle_call(_, _from, state), do: {:reply, :ok, state}

  def handle_info(:init, _state) do
    state = refresh_data()
    {:noreply, state}
  end

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
    case HcAlpha.Node.status() do
      {:ok, response} ->
        response

      _ ->
        %{}
    end
  end
end
