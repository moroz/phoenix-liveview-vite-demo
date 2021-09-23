defmodule TanokiWeb.ActivityChannel do
  use Phoenix.Channel
  alias TanokiWeb.Endpoint
  alias Tanoki.Autologout.Worker

  def join(_channel, _payload, socket) do
    Endpoint.subscribe("activity:" <> socket.assigns.channel_id)
    {:ok, socket}
  end

  def handle_in("ping", _payload, socket) do
    case Worker.ping(socket.assigns.channel_id) do
      {:pong, _} ->
        {:noreply, socket}

      _ ->
        kick_out(socket)
    end
  end

  def handle_info(%{event: "logout"}, socket) do
    kick_out(socket)
  end

  defp kick_out(socket) do
    push(socket, "logout", %{})
    {:noreply, socket}
  end
end
