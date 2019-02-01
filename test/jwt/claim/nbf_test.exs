defmodule JWT.Claim.NbfTest do
  use ExUnit.Case

  alias JWT.Claim.Nbf

  doctest Nbf

  test "reject/1 w nbf_time now returns false" do
    nbf_time = DateTime.to_unix(DateTime.utc_now)
    refute Nbf.reject?(nbf_time, %{})
  end

  test "reject/1 w nbf_time after now returns true" do
    nbf_time = DateTime.to_unix(DateTime.utc_now) + 1
    assert Nbf.reject?(nbf_time, %{})
  end

  test "reject/1 w/o numeric nbf_time returns true" do
    assert Nbf.reject?("a", %{})
  end
end
