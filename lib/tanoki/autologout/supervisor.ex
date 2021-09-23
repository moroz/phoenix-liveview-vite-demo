defmodule Tanoki.Autologout.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg)
  end

  @impl true
  def init(_opts) do
    children = [
      {Tanoki.Autologout.WorkerRegistry, []},
      {Tanoki.Autologout.WorkerSupervisor, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
