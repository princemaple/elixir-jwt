defmodule JWT.ClaimTest do
  use ExUnit.Case

  doctest JWT.Claim

  @now DateTime.to_unix(DateTime.utc_now)
  @after_now (@now + 5)
  @before_now (@now - 5)

  test "verify/2 w rejected_claims" do
    claims = %{"exp" => @before_now}
    assert {:error, _rejected_claims} = JWT.Claim.verify(claims, %{})
  end

  test "verify/2 w/o rejected_claims" do
    claims = %{"exp" => @after_now}
    assert :ok == JWT.Claim.verify(claims, %{})
  end

  @uri "http://www.example.com"
  @recipient "recipient"

  @issuer "issuer"
  @jwt_id "jwt_id"
  @subject "subject"

  @default_options %{
    aud: @uri,
    iss: @issuer,
    jti: @jwt_id,
    sub: @subject
  }

  @default_claims %{
    "aud" => [@uri, @recipient],
    "exp" => @after_now,
    "iat" => @before_now,
    "iss" => @issuer,
    "jti" => @jwt_id,
    "nbf" => @before_now,
    "sub" => @subject
  }

  @invalid_claims %{
    "aud" => ["http://www.other.com", "other recipient"],
    "exp" => @before_now,
    "iat" => @after_now,
    "iss" => "other issuer",
    "jti" => "other jwt_id",
    "nbf" => @after_now,
    "sub" => "other subject"
  }

  test "verify/2 w valid claims, returns :ok" do
    assert :ok == JWT.Claim.verify(@default_claims, @default_options)
  end

  test "verify/2 w invalid claims, returns {:error, [rejected_claims]}" do
    {:error, result} = JWT.Claim.verify(@invalid_claims, @default_options)
    result_len = length(result)
    expected_len = length(Enum.into(@invalid_claims, []))
    assert expected_len == result_len
  end
end
