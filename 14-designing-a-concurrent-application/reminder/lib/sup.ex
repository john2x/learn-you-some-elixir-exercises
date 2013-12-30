defmodule Reminder.Sup do
  def start(mod, args) do
    spawn(__MODULE__, :init, [{ mod, args }])
  end
  def start_link(mod, args) do
    spawn_link(__MODULE__, :init, [{ mod, args }])
  end
  def init({ mod, args }) do
    Process.flag(:trap_exit, true)
    loop({ mod, :start_link, args })
  end
  def loop({ m, f, a }) do
    pid = apply(m, f, a)
    receive do
      { :EXIT, _from, :shutdown } ->
        exit(:shutdown)
      { :EXIT, ^pid, reason } ->
        :io.format("Process ~p exited for reason ~p~n", [pid, reason])
        loop({ m, f, a })
    end
  end
end
