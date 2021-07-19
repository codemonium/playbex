defmodule Playbex.Scheduler do
  def init(pid, data: [], shift_by: _milliseconds) do
    Process.send_after(pid, :stop, 0)
  end

  def init(pid, data: data, shift_by: milliseconds) do
    %{relative_timestamp: next_relative_timestamp} = hd(data)

    delay = max(next_relative_timestamp - milliseconds, 0) |> trunc()

    Process.send_after(pid, :execute, delay)
  end

  def run(pid, data: [], shift_by: _, current_relative_timestamp: _, drift: _) do
    Process.send_after(pid, :stop, 0)
  end

  def run(pid,
        data: data,
        shift_by: milliseconds,
        current_relative_timestamp: current_relative_timestamp,
        drift: drift
      ) do
    %{relative_timestamp: next_relative_timestamp} = hd(data)

    delay =
      max(next_relative_timestamp - milliseconds - current_relative_timestamp - drift, 0)
      |> trunc()

    Process.send_after(pid, :execute, delay)
  end
end
