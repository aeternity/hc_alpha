defmodule HcAlphaWeb.ValidatorsLive do
  use HcAlphaWeb, :live_view

  alias HcAlpha.Pos.Validators

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Validators.subscribe()
    end

    validators = Validators.list_top() |> sort()

    socket =
      socket
      |> assign(:validators, validators)

    {:ok, socket}
  end

  @impl true
  def handle_info({:validators, v}, socket) do
    v_sorted =
    {:noreply, update(socket, :validators, fn _ -> sort(v) end)}
  end

  defp sort(v), do: Enum.sort_by(v, &({&1.status, &1.address}), :desc)
end
