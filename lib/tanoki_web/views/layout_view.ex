defmodule TanokiWeb.LayoutView do
  use TanokiWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  @dev Mix.env() == :dev

  def dev?, do: @dev

  def flash_class("error"), do: "message is-danger"
  def flash_class(other), do: "message is-#{other}"
end
