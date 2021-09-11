defmodule TanokiWeb.WrongLive do
  use TanokiWeb, :live_view
  import ShorterMaps

  def mount(_params, ~m{user_token, live_socket_id}, socket) do
    user = Tanoki.Accounts.get_user_by_session_token(user_token)

    {:ok,
     assign(socket, score: 0, message: "Guess a number.", user: user, session_id: live_socket_id)}
  end

  def render(assigns) do
    ~H"""
    <h1 class="title">Your score: <%= @score %></h1>
    <p><%= inspect(@user) %></p>
    <p><code><%= @session_id %></code></p>
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
