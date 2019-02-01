defmodule JWT.Claim.ExpTest do
  use ExUnit.Case

  alias JWT.Claim.Exp

  doctest Exp

  test "reject/1 w exp_time after now returns false" do
    exp_time = DateTime.to_unix(DateTime.utc_now) + 1
    refute Exp.reject?(exp_time, %{})
  end

  test "reject/1 w exp_time now returns true" do
    exp_time = DateTime.to_unix(DateTime.utc_now)
    assert Exp.reject?(exp_time, %{})
  end

  test "reject/1 w/o numeric exp_time returns true" do
    assert Exp.reject?("a", %{})
  end
end
