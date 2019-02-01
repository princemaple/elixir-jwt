defmodule JWT.Claim.IssTest do
  use ExUnit.Case

  alias JWT.Claim.Iss

  doctest Iss

  @issuer "issuer"

  test "reject?/2 w :iss claim match" do
    refute Iss.reject?(@issuer, %{iss: @issuer})
  end

  test "reject?/2 w/o :iss claim match" do
    assert Iss.reject?(@issuer, %{iss: "not issuer"})
  end

  test "reject?/2 w :iss claim an empty string" do
    assert Iss.reject?("", %{iss: @issuer})
  end

  test "reject?/2 w options[:iss] an empty string" do
    assert Iss.reject?(@issuer, %{iss: ""})
  end
end
