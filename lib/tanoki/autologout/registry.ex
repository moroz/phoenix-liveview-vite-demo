defmodule Tanoki.Autologout.WorkerRegistry do
  def start_link do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def find(key) do
    {:via, Registry, {__MODULE__, key}}
  end
end
