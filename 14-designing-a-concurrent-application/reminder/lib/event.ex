defmodule Reminder.Event do
  defrecord State, server: nil, name: "", to_go: 0

  def start(event_name, date_time), do:
    spawn(__MODULE__, :init, [self(), event_name, date_time])

  def start_link(event_name, date_time), do:
    spawn_link(__MODULE__, :init, [self(), event_name, date_time])

  def init(server, event_name, date_time), do:
    loop(State.new(server: server,
                   name: event_name,
                   to_go: time_to_go(date_time)))

  def cancel(pid) do
    ref = Process.monitor(pid)
    pid <- { self(), ref, :cancel }
    receive do
      { ^ref, :ok } ->
        Process.demonitor(ref, [:flush]);
        :ok
      { 'DOWN', ^ref, :process, ^pid, _reason } ->
        :ok
    end
  end

  def loop(State[server: server, to_go: [t|next]] = state) do
    receive do
      { server, ref, :cancel } ->
        server <- { ref, :ok }
    after t * 1000 ->
      if next == [] do
        server <- { :done, state.name }
      else
        loop(state.to_go(next))
      end
    end
  end

  def normalize(n) do
    limit = 49*24*60*60
    [rem(n, limit) | List.duplicate(div(n, limit), limit)]
  end

  def time_to_go(timeout={{ _, _, _ }, { _, _, _ }}) do
    now = :calendar.local_time
    to_go = :calendar.datetime_to_gregorian_seconds(timeout) -
            :calendar.datetime_to_gregorian_seconds(now)
    secs = if to_go > 0 do to_go else 0 end
    normalize(secs)
  end
end

