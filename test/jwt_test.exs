defmodule JWTTest do
  use ExUnit.Case

  doctest JWT

  @hs256_key "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
  @key_id "test-key"
  @claims %{"abc" => "def", "num" => 1300819380, "http://example.com/is_root" => true}

  defp sign_does_verify(options, claims \\ @claims) do
    jwt = JWT.sign(claims, options)
    {:ok, verified_claims} = JWT.verify(jwt, options)
    assert verified_claims === claims
  end

  test "sign/2 w 'none' alg (and no key) does verify/2" do
    sign_does_verify(%{alg: "none"})
  end

  test "sign/2 w default alg (HS256) does verify/2" do
    sign_does_verify(%{key: @hs256_key})
  end

  test "sign/2 w explicit alg does verify/2" do
    sign_does_verify(%{alg: "HS256", key: @hs256_key})
  end

  test "sign/2 w explicit alg and wrong key returns error" do
    wrong_key = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9Z"
    options = %{alg: "HS256", key: @hs256_key}
    jwt = JWT.sign(@claims, options)
    assert {:error, :invalid_signature} == JWT.verify(jwt, %{alg: "HS256", key: wrong_key})
  end

  test "unify_header/1 w key, w/o alg returns default alg and filters key" do
    assert JWT.unify_header(key: @hs256_key) == %{typ: "JWT", alg: "HS256"}
  end

  test "unify_header/1 w key, w alg returns alg and filters key" do
    assert JWT.unify_header(alg: "RS256", key: "rs_256_key") == %{typ: "JWT", alg: "RS256"}
  end

  test "unify_header/1 w/o key, w alg 'none'" do
    assert JWT.unify_header(alg: "none") == %{typ: "JWT", alg: "none"}
  end

  test "unify_header/1 with key and key id includes the key id" do
    assert JWT.unify_header(key: @hs256_key, kid: @key_id) == %{typ: "JWT", alg: "HS256", kid: "test-key"}
  end

  test "unify_header/1 excludes header that is not registered" do
    assert JWT.unify_header(key: @hs256_key, notstandard: "value") == %{typ: "JWT", alg: "HS256"}
  end
end
