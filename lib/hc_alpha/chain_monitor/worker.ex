defmodule HcAlpha.ChainMonitor.Worker do

  @callback interval() :: integer()
  @callback init() :: any()
  @callback refresh(any()) :: any()

  defmacro __using__(_args) do
    quote do

      def state(), do: GenServer.call(__MODULE__, :state)

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
        {:ok, %{interval: interval(), data: init()}}
      end

      def handle_call(:state, _, state), do: {:reply, state.data, state}
      def handle_call(_, _, state), do: {:reply, :ok, state}

      def handle_info(:refresh, state) do
        data = refresh(state.data)
        refresh_timer(state.interval)
        {:noreply, %{state | data: data}}
      end

      def handle_info(_, state), do: {:noreply, state}

      def refresh_timer(interval) do
        Process.send_after(self(), :refresh, interval)
      end

    end
  end

end
