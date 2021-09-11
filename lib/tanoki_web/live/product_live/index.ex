defmodule TanokiWeb.ProductLive.Index do
  use TanokiWeb, :live_view

  alias Tanoki.Catalog
  alias Tanoki.Catalog.Product

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :products, list_products())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Catalog.get_product!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Catalog.get_product!(id)
    {:ok, _} = Catalog.delete_product(product)

    {:noreply, assign(socket, :products, list_products())}
  end

  def handle_event("show", %{"id" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.product_show_path(socket, :show, id))}
  end

  defp list_products do
    Catalog.list_products()
  end
end
