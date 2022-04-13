defmodule HcAlpha.Pos.Delegates do
  alias HcAlpha.Pos

  @pubsub "delegates"

  def subscribe(), do: Pos.subscribe(@pubsub)

  def broadcast(msg) do
    Pos.broadcast(@pubsub, {:delegates, msg})
    msg
  end
end
