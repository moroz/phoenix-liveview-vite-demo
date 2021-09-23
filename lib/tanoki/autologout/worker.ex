defmodule Tanoki.Autologout.Worker do
  @behaviour :gen_statem

  import Logger
  alias Tanoki.Autologout.WorkerRegistry

  defmodule State do
    defstruct started_at: nil, last_heartbeat_at: nil, channel: nil, timeout_time: nil

    def new(attrs \\ []) do
      __MODULE__
      |> struct!(attrs)
      |> Map.put(:started_at, now())
      |> Map.update!(:timeout_time, fn val -> val || default_timeout() end)
    end

    def refesh(%__MODULE__{} = state) do
      %{state | last_heartbeat_at: now()}
    end

    defp default_timeout do
      :tanoki
      |> Application.get_env(Tanoki.Autologout, [])
      |> Keyword.get(:timeout_time, 15 * 60 * 1000)
    end

    defp now, do: :os.system_time(:seconds)
  end

  def callback_mode, do: [:state_functions, :state_enter]

  def start_link(name, init_arg \\ []) do
    :gen_statem.start_link(name, __MODULE__, init_arg, [])
  end

  def ping({:via, _, _} = via_tuple) do
    :gen_statem.call(via_tuple, :ping)
  end

  def ping(pid) when is_pid(pid) do
    :gen_statem.call(pid, :ping)
  end

  def ping(channel_id) when is_binary(channel_id) do
    via_tuple = WorkerRegistry.via_tuple(channel_id)
    ping(via_tuple)
  end

  def init(opts \\ []) do
    {:ok, :alive, State.new(opts)}
  end

  defp timeout(state) do
    {:timeout, state.timeout_time, :timeout}
  end

  def alive(:enter, _old_state, state) do
    debug("Entering alive")
    {:keep_state, state, [timeout(state)]}
  end

  def alive(:timeout, _event, state) do
    {:next_state, :dead, state}
  end

  def alive({:call, from}, :ping, state) do
    {:keep_state, State.refesh(state),
     [timeout(state), {:reply, from, {:pong, state.timeout_time}}]}
  end

  def dead(:enter, _prev_state, %{channel: channel}) do
    debug("Kicking out everyone in channel #{inspect(channel)}")
    {:stop, :normal}
  end
end
