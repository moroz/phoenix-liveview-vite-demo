defmodule TanokiWeb.WrongLive do
  use TanokiWeb, :live_view
  import ShorterMaps

  def mount(_params, _session, socket) do
    {:ok, assign(socket, score: 0, message: "Guess a number.")}
  end

  def render(assigns) do
    ~H"""
    <h1>Your score: <%= @score %></h1>
    <h2><%= @message %></h2>
    <h2>
      <%= for n <- 1..10 do %>
        <button phx-click="guess" phx-value-number={n} class="button is-primary is-large"><%= n %></button>
      <% end %>
    </h2>
    """
  end

  def handle_event("guess", ~m{number}, socket) do
    score = socket.assigns[:score] + String.to_integer(number)
    {:noreply, assign(socket, score: score)}
  end
end
