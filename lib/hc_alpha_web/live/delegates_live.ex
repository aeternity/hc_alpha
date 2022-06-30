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
    stake = Decimal.new(delegate.shares)
    ae = Decimal.from_float(:math.pow(10, 18))

    Decimal.div(stake, ae)
    |> Decimal.normalize()
    |> Decimal.to_string(:normal)
  end

  def to_percent_shares(delegate) do
    shares = Decimal.new(delegate.shares)
    total_shares = Decimal.new(delegate.total_shares)

    Decimal.div(shares, total_shares)
    |> Decimal.mult(100)
    |> Decimal.normalize()
    |> Decimal.to_string(:normal)
  end

  def to_stake(delegate) do
    shares = Decimal.new(delegate.shares)
    total_shares = Decimal.new(delegate.total_shares)
    total_stake = Decimal.new(delegate.total_stake)

    Decimal.mult(shares, total_stake)
    |> Decimal.div(total_shares)
    |> Decimal.to_float()
    |> aetto_to_ae()
  end

  defp aetto_to_ae(aetto), do: aetto / :math.pow(10, 18)
end
