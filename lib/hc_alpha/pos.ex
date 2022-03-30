defmodule HcAlpha.Pos do
  def subscribe(:leaders), do: subscribe("leaders")
  def subscribe(topic), do: Phoenix.PubSub.subscribe(HcAlpha.PubSub, topic)

  def broadcast(:elect_next, msg), do: broadcast("leaders", {:next_leader, msg})
  def broadcast(:leader, msg), do: broadcast("leaders", {:current_leader, msg})
  def broadcast(topic, msg), do: Phoenix.PubSub.broadcast(HcAlpha.PubSub, topic, msg)
end
