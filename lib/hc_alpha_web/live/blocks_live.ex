defmodule HcAlphaWeb.BlocksLive do
  use HcAlphaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      HcAlpha.Blocks.subscribe()
    end

    distribution = HcAlpha.Blocks.distribution()
    key_blocks = HcAlpha.Blocks.list(25)

    socket =
      socket
      |> assign(:distribution, distribution)
      |> assign(:key_blocks, key_blocks)

    {:ok, socket}
  end

  @impl true
  def handle_info({:key_blocks, new_blocks}, socket) do
    distribution = HcAlpha.Blocks.distribution()

    socket =
      socket
      |> update(:distribution, fn _ -> distribution end)
      |> update(:key_blocks, fn old -> update_key_blocks(old, new_blocks) end)

    {:noreply, socket}
  end

  def update_key_blocks(old, new) do
    new ++ old
    |> Enum.sort(fn l, r -> l.height >= r.height end)
    |> Enum.take(25)
  end

end
