defmodule Roads do
  def main([filename]) do
    { :ok, bin } = File.read filename
    map = parse_map bin
    optimal_path map
  end

  def parse_map(bin) when is_binary(bin) do
    values = lc x inlist String.split(bin), do: binary_to_integer x
    group_vals values, []
  end

  def group_vals([], acc), do: Enum.reverse acc
  def group_vals([a, b, x | rest], acc), do: group_vals(rest, [{ a, b, x } | acc])

  def shortest_step({ a, b, x }, {{ dist_a, path_a}, { dist_b, path_b }}) do
    opt_a1 = { dist_a + a, [{ :a, a } | path_a] }
    opt_a2 = { dist_b + b + x, [{ :x, x }, { :b, b } | path_b] }
    opt_b1 = { dist_b + b, [{ :b, b } | path_b] }
    opt_b2 = { dist_a + a + x, [{ :x, x }, { :a, a } | path_a] }
    { min(opt_a1, opt_a2), min(opt_b1, opt_b2) }
  end

  def optimal_path(map) do
    { a, b } = List.foldl(map, {{ 0, [] }, { 0, [] }}, &shortest_step/2)
    { _dist, path } = cond do
      hd(elem(a, 1)) !== { :x, 0 } -> a
      hd(elem(b, 1)) !== { :x, 0 } -> b
    end
    Enum.reverse path
  end
end

