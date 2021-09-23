defmodule Tanoki.Autologout.Worker do
  @behaviour :gen_statem

  def callback_mode, do: [:state_functions, :state_enter]

  import Logger

  def start_link(opts) do
    GenStateMachine.start_link(__MODULE__, [], opts)
  end

  def init(_opts \\ []) do
    {:ok, :off, []}
  end

  def off(:enter, _old_state, data) do
    debug("Entering off")
    {:keep_state, data}
  end

  def off({:call, from}, :toggle, data) do
    debug("Received toggle event")
    {:next_state, :on, data, [{:reply, from, :on}]}
  end

  def on(:timeout, _, data) do
    debug("On state timed out")
    {:next_state, :off, data}
  end

  def on(:enter, _old_state, data) do
    debug("Entering on")
    {:keep_state, data, [{:timeout, 5000, :timeout}]}
  end
end
