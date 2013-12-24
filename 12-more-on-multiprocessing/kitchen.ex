defmodule Kitchen do
  def start(food_list), do: spawn(__MODULE__, :fridge2, [food_list])

  def fridge1() do
    receive do
      { from, { :store, _food }} ->
        from <- { self(), :ok };
        fridge1()
      { from, { :take, _food }} ->
        from <- { self(), :not_found };
        fridge1()
      :terminate -> :ok
    end
  end

  def fridge2(food_list) do
    receive do
      { from, { :store, food }} ->
        from <- { self(), :ok };
        fridge2([food | food_list])
      { from, { :take, food }} ->
        case :lists.member(food, food_list) do
          true ->
            from <- { self(), { :ok, food }};
            fridge2(:lists.delete(food, food_list))
          false ->
            from <- { self(), :not_found };
            fridge2(food_list)
        end
      :terminate -> :ok
    end
  end

  def store(pid, food) do
    pid <- { self(), { :store, food }}
    receive do
      { ^pid, msg } -> msg
    end
  end

  def take(pid, food) do
    pid <- { self(), { :take, food }}
    receive do
      { ^pid, msg } -> msg
    end
  end

  def store2(pid, food) do
    pid <- { self(), { :store, food }}
    receive do
      { ^pid, msg } -> msg
    after
      3000 -> :timeout
    end
  end

  def take2(pid, food) do
    pid <- { self(), { :take, food }}
    receive do
      { ^pid, msg } -> msg
    after
      3000 -> :timeout
    end
  end

end
