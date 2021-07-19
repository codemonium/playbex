defmodule Playbex.Server do
  use GenServer, restart: :transient

  require Logger

  alias Playbex.Scheduler

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  @impl true
  def init(%{data: data, callback: callback, shift_by: milliseconds}) do
    Process.flag(:trap_exit, true)

    started_at = NaiveDateTime.utc_now()

    Scheduler.init(self(), data: data, shift_by: milliseconds)

    {:ok, %{data: data, callback: callback, shift_by: milliseconds, started_at: started_at}}
  end

  @impl true
  def handle_info(:execute, %{
        data: data,
        callback: callback,
        shift_by: milliseconds,
        started_at: started_at
      }) do
    [current_data | future_data] = data

    current_relative_timestamp = current_data.relative_timestamp - milliseconds

    callback.(%{current_data | relative_timestamp: current_relative_timestamp})

    now = NaiveDateTime.utc_now()
    drift = NaiveDateTime.diff(now, started_at, :millisecond) - current_relative_timestamp

    Scheduler.run(self(),
      data: future_data,
      shift_by: milliseconds,
      current_relative_timestamp: current_relative_timestamp,
      drift: drift
    )

    {:noreply,
     %{data: future_data, callback: callback, shift_by: milliseconds, started_at: started_at}}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.debug("Terminating: #{inspect(reason)}, #{inspect(state)}")
  end
end
