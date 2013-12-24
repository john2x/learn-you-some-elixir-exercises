defmodule LinkMon do
  def myproc() do
    :timer.sleep(5000)
    exit(:reason)
  end

  def chain(0) do
    receive do
      _ -> :ok
    after 2000 -> exit("chain dies here")
    end
  end
  def chain(n) do
    pid = spawn(chain(n-1))
    Process.link(pid)
    receive do
      _ -> :ok
    end
  end

  def start_critic() do
    spawn(__MODULE__, :critic, [])
  end

  def start_critic2() do
    spawn(__MODULE__, :restarter, [])
  end

  def restarter() do
    Process.flag(:trap_exit, true)
    pid = spawn_link(__MODULE__, :critic2, [])
    Process.register(pid, :critic)
    receive do
      { 'EXIT', ^pid, :normal } -> :ok
      { 'EXIT', ^pid, :shutdown } -> :ok
      { 'EXIT', ^pid, _ } -> restarter()
    end
  end

  def judge(pid, band, album) do
    pid <- { self(), { band, album }}
    receive do
      { ^pid, criticism } -> criticism
    after 2000 -> :timeout
    end 
  end

  def judge2(band, album) do
    ref = make_ref
    :critic <- { self(), ref, { band, album }}
    receive do
      { ^ref, criticism } -> criticism
    after 2000 -> :timeout
    end 
  end

  def critic() do
    receive do
      { from, {"Rage Against the Turing Machine", "Unit Testify"}} ->
        from <- { self(), "They are great!" }
      { from, {"System of a Downtime", "Memoize"}} ->
        from <- { self(), "They're not Johnny Crash but they're good." }
      { from, {"Johnny Crash", "The Token Ring of Fire"}} ->
        from <- { self(), "Simply incredible." }
      { from, { _band, _album }} ->
        from <- { self(), "They are terrible!" }
    end
    critic()
  end
  def critic2() do
    receive do
      { from, ref, {"Rage Against the Turing Machine", "Unit Testify"}} ->
        from <- { ref, "They are great!" }
      { from, ref, {"System of a Downtime", "Memoize"}} ->
        from <- { ref, "They're not Johnny Crash but they're good." }
      { from, ref, {"Johnny Crash", "The Token Ring of Fire"}} ->
        from <- { ref, "Simply incredible." }
      { from, ref, { _band, _album }} ->
        from <- { ref, "They are terrible!" }
    end
    critic2()
  end
end

