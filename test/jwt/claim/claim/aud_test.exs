defmodule JWT.Claim.AudTest do
  use ExUnit.Case

  alias JWT.Claim.Aud

  doctest Aud

  @recipient "recipient"
  @uri "http://www.example.com"
  @aud [@uri, @recipient]

  test "reject?/2 w :aud claim a list w recipient match" do
    refute Aud.reject?(@aud, %{aud: @recipient})
  end

  test "reject?/2 w :aud claim a list w uri match" do
    refute Aud.reject?(@aud, %{aud: @uri})
  end

  test "reject?/2 w :aud claim a list w/o match" do
    assert Aud.reject?(@aud, %{aud: "not recipient"})
  end

  test "reject?/2 w :aud claim a list w/o options[:aud]" do
    assert Aud.reject?(@aud, %{})
  end

  test "reject?/2 w :aud claim a string w match" do
    refute Aud.reject?(@recipient, %{aud: @recipient})
  end

  test "reject?/2 w :aud claim a string w/o match" do
    assert Aud.reject?(@recipient, %{aud: "not recipient"})
  end

  test "reject?/2 w :aud claim a string w/o options[:aud]" do
    assert Aud.reject?(@recipient, %{})
  end

  defp with_a_blank_aud_claim(aud) do
    assert Aud.reject?(aud, %{aud: @recipient})
  end

  test "reject?/2 w :aud claim an empty list", do: with_a_blank_aud_claim([])

  test "reject?/2 w :aud claim a list w an empty string", do: with_a_blank_aud_claim([""])

  test "reject?/2 w :aud claim an empty string", do: with_a_blank_aud_claim("")

  test "reject?/2 w options[:aud] an empty string" do
    assert Aud.reject?(@recipient, %{aud: ""})
  end
end
