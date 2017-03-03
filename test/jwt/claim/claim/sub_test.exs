defmodule JWT.Claim.SubTest do
  use ExUnit.Case

  alias JWT.Claim.Sub

  doctest Sub

  @subject "subject"

  test "reject?/2 w :sub claim match" do
    refute Sub.reject?(@subject, %{sub: @subject})
  end

  test "reject?/2 w/o :sub claim match" do
    assert Sub.reject?(@subject, %{sub: "not subject"})
  end

  test "reject?/2 w :sub claim an empty string" do
    assert Sub.reject?("", %{sub: @subject})
  end

  test "reject?/2 w options[:sub] an empty string" do
    assert Sub.reject?(@subject, %{sub: ""})
  end
end
