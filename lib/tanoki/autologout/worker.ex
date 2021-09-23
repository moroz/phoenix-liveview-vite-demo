defmodule Tanoki.Autologout.Worker do
  @behaviour :gen_statem

  import Logger
  alias Tanoki.Autologout.WorkerRegistry
  alias Tanoki.Accounts

  defmodule State do
    defstruct started_at: nil,
              last_heartbeat_at: nil,
              channel_id: nil,
              timeout_time: nil,
              user_token: nil

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
      |> Keyword.get(:timeout_time, 15000)
    end

    defp now, do: :os.system_time(:seconds)
  end

  def callback_mode, do: [:state_functions, :state_enter]

  def start_link(name, init_arg \\ []) do
    :gen_statem.start_link(name, __MODULE__, init_arg, [])
  end

  def ping(channel_id) do
    case WorkerRegistry.lookup_by_channel_id(channel_id) do
      pid when is_pid(pid) ->
        :gen_statem.call(pid, :ping)

      _ ->
        {:error, :dead}
    end
  end

  def init(opts \\ []) do
    {:ok, :alive, State.new(opts)}
  end

  defp timeout(state) do
    {:timeout, state.timeout_time, :timeout}
  end

  def alive(:enter, _old_state, state) do
    {:keep_state, state, [timeout(state)]}
  end

  def alive(:timeout, _event, state) do
    debug("Time out")
    {:next_state, :dead, state}
  end

  def alive({:call, from}, :ping, state) do
    debug("Received a :ping from channel #{state.channel_id}, timeout #{state.timeout_time}")

    {:keep_state, State.refesh(state),
     [timeout(state), {:reply, from, {:pong, state.timeout_time}}]}
  end

  def dead(:enter, _prev_state, %State{channel_id: channel_id, user_token: token}) do
    debug("Kicking out everyone in channel #{inspect(channel_id)}")
    Accounts.delete_session_token(token)
    TanokiWeb.Endpoint.broadcast!("activity:#{channel_id}", "logout", %{})
    {:stop, :normal}
  end
end
