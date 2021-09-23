defmodule Tanoki.Autologout.WorkerSupervisor do
  use DynamicSupervisor
  alias Tanoki.Autologout.WorkerRegistry
  alias Tanoki.Autologout.Worker

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(channel_id) do
    name = WorkerRegistry.via_tuple(channel_id)

    child_spec = %{
      id: Worker,
      start: {Worker, :start_link, [name, [channel: channel_id]]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
