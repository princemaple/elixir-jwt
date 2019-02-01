defmodule JWT.Claim.IatTest do
  use ExUnit.Case

  alias JWT.Claim.Iat

  doctest Iat

  test "reject/1 w iat_time before now returns false" do
    iat_time = DateTime.to_unix(DateTime.utc_now) - 1
    refute Iat.reject?(iat_time, %{})
  end

  test "reject/1 w iat_time after now returns true" do
    iat_time = DateTime.to_unix(DateTime.utc_now) + 1
    assert Iat.reject?(iat_time, %{})
  end

  test "reject/1 w/o numeric iat_time returns true" do
    assert Iat.reject?("a", %{})
  end
end
