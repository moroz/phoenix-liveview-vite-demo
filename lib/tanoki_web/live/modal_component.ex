defmodule TanokiWeb.ModalComponent do
  use TanokiWeb, :live_component

  def modal_class(falsey) when falsey in [nil, false], do: "modal-overlay"
  def modal_class(_), do: "modal-overlay is-shown"

  def overlay(assigns) do
    ~H"""
    <%= live_patch("", to: @return_to, class: modal_class(@active)) %>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <modal
      id={@id}
      class="phx-modal"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target={@myself}
      phx-page-loading>
      <%= live_patch raw("&times;"), to: @return_to, class: "phx-modal-close" %>
      <%= live_component @component, @opts %>
    </modal>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
