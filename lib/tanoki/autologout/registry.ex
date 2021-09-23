defmodule Tanoki.Autologout.WorkerRegistry do
  def start_link(_opts) do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end
end
