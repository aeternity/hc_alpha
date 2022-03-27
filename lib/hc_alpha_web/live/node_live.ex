defmodule HcAlphaWeb.NodeLive do
  use HcAlphaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      HcAlpha.Pos.subscribe(:leaders)
    end

    socket =
      socket
      |> assign(:current, "...")
      |> assign(:next, "...")

    {:ok, socket}
  end

  @impl true
  def handle_info({:current_leader, address}, socket) do
    {:noreply, update(socket, :current, fn _ -> address end)}
  end

  def handle_info({:next_leader, address}, socket) do
    {:noreply, update(socket, :next, fn _ -> address end)}
  end
end
