defmodule JWT.Claim.JtiTest do
  use ExUnit.Case

  alias JWT.Claim.Jti

  doctest Jti

  @jwt_id "jwt_id"

  test "reject?/2 w :jti claim match" do
    refute Jti.reject?(@jwt_id, %{jti: @jwt_id})
  end

  test "reject?/2 w/o :jti claim match" do
    assert Jti.reject?(@jwt_id, %{jti: "not jwt_id"})
  end

  test "reject?/2 w :jti claim an empty string" do
    assert Jti.reject?("", %{jti: @jwt_id})
  end

  test "reject?/2 w options[:jti] an empty string" do
    assert Jti.reject?(@jwt_id, %{jti: ""})
  end
end
