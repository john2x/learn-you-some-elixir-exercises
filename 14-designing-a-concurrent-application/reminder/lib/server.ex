defmodule Reminder.Server do
  require Reminder.Event

  defrecord State, events: HashDict.new, clients: HashDict.new
  defrecord Event, name: "", description: "", pid: nil, timeout: {{ 1970, 1, 1, }, { 0, 0, 0 }}

  def init() do
    loop(State.new(
      events: HashDict.new,
      clients: HashDict.new
    ))
  end

  def start() do
    pid = spawn(__MODULE__, :init, [])
    Process.register pid, __MODULE__
    pid
  end

  def start_link() do
    pid = spawn_link(__MODULE__, :init, [])
    Process.register pid, __MODULE__
    pid
  end

  def terminate() do
    __MODULE__ <- :shutdown
  end

  def subscribe(pid) do
    ref = Process.monitor(Process.whereis(__MODULE__))
    __MODULE__ <- { self(), ref, { :subscribe, pid }}
    receive do
      { ^ref, :ok } ->
        { :ok, ref }
      { 'DOWN', ^ref, :process, _pid, reason } ->
        { :error, reason }
    after 5000 ->
      { :error, :timeout }
    end
  end

  def add_event(name, description, timeout) do
    ref = make_ref()
    __MODULE__ <- { self(), ref, { :add, name, description, timeout }}
    receive do
      { ^ref, msg } -> msg
    after 5000 ->
      { :error, :timeout }
    end
  end

  def add_event2(name, description, timeout) do
    ref = make_ref()
    __MODULE__ <- { self(), ref, { :add, name, description, timeout }}
    receive do
      { ^ref, { :error, reason }} -> raise ErlangError.new(original: reason)
      { ^ref, msg } -> msg
    after 5000 ->
      { :error, :timeout }
    end
  end

  def cancel(name) do
    ref = make_ref()
    __MODULE__ <- { self(), ref, { :cancel, name }}
    receive do
      { ^ref, :ok } -> :ok
    after 5000 -> { :error, :timeout }
    end
  end

  def listen(delay) do
    receive do
      m = { :done, _name, _description } ->
        [m | listen(0)]
    after delay * 1000 -> []
    end
  end

  def loop(state) do
    receive do
      { pid, msg_ref, { :subscribe, client }} ->
        ref = Process.monitor(client)
        new_clients = HashDict.put(state.clients, ref, client)
        pid <- { msg_ref, :ok }
        loop(state.clients(new_clients))

      { pid, msg_ref, { :add, name, description, timeout }} ->
        if valid_datetime(timeout) do
          event_pid = Reminder.Event.start_link(name, timeout)
          new_events = HashDict.put(
            state.events, name, Event.new(
              name: name, description: description,
              pid: event_pid, timeout: timeout
            ))
          pid <- { msg_ref, :ok }
          loop(state.events(new_events))
        else
          pid <- { msg_ref, { :error, :bad_timeout }}
          loop(state)
        end

      { pid, msg_ref, { :cancel, name }} ->
        events = HashDict.delete(state.events, name)
        pid <- { msg_ref, :ok }
        loop(state.events(events))

      { :done, name } ->
        if HashDict.has_key? state.events, name do
          event = HashDict.get state.events, name
          send_to_clients({ :done, event.name, event.description },
                          state.clients)
          new_events = HashDict.delete(state.events, name)
          loop(state.events(new_events))
        else
          loop(state)
        end

      :shutdown -> exit :shutdown

      { 'DOWN', ref, :process, _pid, _reason } ->
        loop(HashDict.delete(state.clients, ref))

      :code_change ->
        __MODULE__.loop(state)

      unknown ->
        :io.format("Unknown message ~p~n", [unknown])
        loop(state)
    end
  end

  def send_to_clients(msg, client_dict) do
    Enum.map(client_dict, fn ({ _ref, pid }) -> pid <- msg end)
  end

  def valid_datetime({ date, time }) do
    try do
      :calendar.valid_date(date) and valid_time(time)
    rescue
      FunctionClauseError -> false
    end
  end
  def valid_datetime(_), do: false
  
  def valid_time({ h, m, s }), do: valid_time(h, m, s)
  def valid_time(h, m, s) when h >= 0 and h < 24 and m >= 0 and m <= 60 and s >= 0 and s < 60 do
    true
  end
  def valid_time(_, _, _), do: false

  def code_change() do
    ref = make_ref()
    __MODULE__ <- :code_change
    receive do
      { ^ref, :ok } -> :ok
    after 5000 -> { :error, :timeout }
    end
  end
end
