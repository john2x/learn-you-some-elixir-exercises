defmodule Dolphins do
  def dolphin1() do
    receive do
      :do_a_flip -> :io.format("How about no?~n")
      :fish -> :io.format("So long and thanks for all the fish!~n")
      _ -> :io.format("Heh, we're smarter than you humans!~n")
    end
  end

  def dolphin2() do
    receive do
      { from, :do_a_flip } -> from <- "How about no?"
      { from, :fish } -> from <- "So long and thanks for all the fish!"
      _ -> :io.format("Heh, we're smarter than you humans!~n")
    end
  end

  def dolphin3() do
    receive do
      { from, :do_a_flip } ->
        from <- "How about no?";
        dolphin3()
      { from, :fish } ->
        from <- "So long and thanks for all the fish!"
      _ ->
        :io.format("Heh, we're smarter than you humans!~n");
        dolphin3
    end
  end
end
