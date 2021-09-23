defmodule Tanoki.Autologout.WorkerSupervisor do
  use DynamicSupervisor
  alias Tanoki.Autologout.WorkerRegistry
  alias Tanoki.Autologout.Worker

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def find_or_start_worker(channel_id, attrs \\ []) do
    case WorkerRegistry.lookup_by_channel_id(channel_id) do
      nil ->
        start_child(channel_id, attrs)

      pid ->
        {:ok, pid}
    end
  end

  def start_child(channel_id, attrs \\ []) do
    name = WorkerRegistry.via_tuple(channel_id)

    child_spec = %{
      id: Worker,
      start: {Worker, :start_link, [name, [channel_id: channel_id] ++ attrs]},
      restart: :temporary
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
