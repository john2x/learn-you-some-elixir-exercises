ExUnit.start

defmodule CalcTest do
  use ExUnit.Case
  require Calc

  test "Calc.rpn/1" do
    assert Calc.rpn("2 3 +") == 5
    assert Calc.rpn("90 3 -") == 87
    assert Calc.rpn("10 4 3 + 2 * -") == -4
    assert Calc.rpn("10 4 3 + 2 * - 2 /") == -2
    assert_raise MatchError, fn ->
      Calc.rpn("90 34 12 33 55 66 + * - +")
    end
    assert Calc.rpn("90 34 12 33 55 66 + * - + -") == 4037
    assert Calc.rpn("2 3 ^") == 8
    assert Calc.rpn("2 0.5 ^") == :math.sqrt(2)
    assert Calc.rpn("2.7 ln") == :math.log(2.7)
    assert Calc.rpn("2.7 log10") == :math.log10(2.7)
  end
end

