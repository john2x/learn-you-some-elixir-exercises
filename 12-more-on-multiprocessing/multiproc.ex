defmodule Multiproc do
  def sleep(t) do
    receive do
    after t -> :ok
    end
  end
  
  def flush() do
    receive do
      _ -> flush()
    after 0 -> :ok
    end
  end

  def important() do
    receive do
      { priority, message } when priority > 10 ->
        [message | important()]
    after 0 ->
      normal()
    end
  end

  def normal() do
    receive do
      { _, message } ->
        [message | normal()]
    after 0 ->
      []
    end
  end
end
