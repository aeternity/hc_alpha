defmodule HcAlphaWeb.ValidatorsLive do
  use HcAlphaWeb, :live_view

  alias HcAlpha.Pos.Validators

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Validators.subscribe()
    end

    validators = Validators.list()

    socket =
      socket
      |> assign(:validators, validators)

    {:ok, socket}
  end

  @impl true
  def handle_info({:validators, v}, socket) do
    {:noreply, update(socket, :validators, fn _ -> v end)}
  end
end
