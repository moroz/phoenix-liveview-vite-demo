defmodule TanokiWeb.ProductLive.Index do
  use TanokiWeb, :live_view

  alias Tanoki.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :products, list_products())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Product details")
    |> assign(:product, Catalog.get_product!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
  end

  @impl true
  def handle_event("show", %{"id" => id}, socket) do
    {:noreply, push_patch(socket, to: Routes.product_index_path(socket, :show, id))}
  end

  defp list_products do
    Catalog.list_products()
  end

  def modal_class(nil), do: "modal-overlay"
  def modal_class(_), do: "modal-overlay is-shown"
end
