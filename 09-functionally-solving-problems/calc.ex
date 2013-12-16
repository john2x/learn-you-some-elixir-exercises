defmodule Calc do
  def rpn(l) when is_binary(l) do
    [res] = List.foldl String.split(l), [], &rpn/2
    res
  end

  defp rpn("+", [n1, n2 | stack]), do: [n2 + n1 | stack]
  defp rpn("-", [n1, n2 | stack]), do: [n2 - n1 | stack]
  defp rpn("*", [n1, n2 | stack]), do: [n2 * n1 | stack]
  defp rpn("/", [n1, n2 | stack]), do: [n2 / n1 | stack]
  defp rpn("^", [n1, n2 | stack]), do: [:math.pow(n2, n1) | stack]
  defp rpn("ln", [n | stack]),     do: [:math.log(n) | stack]
  defp rpn("log10", [n | stack]),  do: [:math.log10(n) | stack]
  defp rpn(x, stack), do: [read(x) | stack]

  defp read(x) do
    case Float.parse(x) do
      { n, _ } -> n
      :error -> :error
    end
  end
end
