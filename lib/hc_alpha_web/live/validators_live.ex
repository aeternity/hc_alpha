defmodule HcAlphaWeb.ValidatorsLive do
  use HcAlphaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      HcAlpha.Pos.subscribe(:balances)
    end

    balances = HcAlpha.Pos.balances()

    socket =
      socket
      |> assign(:balances, balances)

    {:ok, socket}
  end

  @impl true
  def handle_info({:balances, balances}, socket) do
    {:noreply, update(socket, :balances, fn _ -> balances end)}
  end
end
