defmodule HcAlphaWeb.DelegatesLive do
  use HcAlphaWeb, :live_view

  alias HcAlpha.Pos.Delegates

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Delegates.subscribe()
    end

    %{delegates: delegates} = HcAlpha.ChainMonitor.PosValidators.state()

    socket =
      socket
      |> assign(:delegates, group(delegates))

    {:ok, socket}
  end

  @impl true
  def handle_info({:delegates, d}, socket) do
    {:noreply, update(socket, :delegates, fn _ -> group(d) end)}
  end

  defp group(d), do: Enum.group_by(d, & &1.validator)

  def to_shares(delegate) do
    stake = Decimal.new(delegate.stake)
    ae = Decimal.from_float(:math.pow(10, 18))

    Decimal.div(stake, ae)
    |> Decimal.normalize()
    |> Decimal.to_string(:normal)
  end

  def to_percent_shares(delegate) do
    stake = Decimal.new(delegate.stake)
    total = Decimal.new(delegate.total_shares)

    Decimal.div(stake, total)
    |> Decimal.mult(100)
    |> Decimal.normalize()
    |> Decimal.to_string(:normal)
  end
end
