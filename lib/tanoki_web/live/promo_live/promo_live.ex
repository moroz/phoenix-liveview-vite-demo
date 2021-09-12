defmodule TanokiWeb.PromoLive do
  use TanokiWeb, :live_view

  alias Tanoki.Promo
  alias Tanoki.Promo.Recipient

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_recipient()
     |> assign_changeset()}
  end

  def assign_recipient(socket) do
    assign(socket, :recipient, %Recipient{})
  end

  def assign_changeset(%{assigns: %{recipient: recipient}} = socket) do
    changeset = Promo.change_recipient(recipient)
    assign(socket, :changeset, changeset)
  end

  def handle_event(
        "validate",
        %{"recipient" => recipient_params},
        %{assigns: %{recipient: recipient}} = socket
      ) do
    changeset =
      recipient
      |> Promo.change_recipient(recipient_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end
end
