defmodule JWT.JwsTest do
  use ExUnit.Case

  alias JWT.Jws

  doctest Jws

  @hs256_key "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
  @payload "{\"iss\":\"joe\",\"exp\":1300819380,\"http://example.com/is_root\":true}"

  defp plausible_jws?(jws, bytesize \\ 32) do
    parts = String.split(jws, ".")
    assert length(parts) == 3
    [_, _, encoded_mac] = parts
    assert byte_size(Base.url_decode64!(encoded_mac, padding: false)) == bytesize
  end

  test "sign/3 for HS256 does verify/3 and is plausible" do
    alg = "HS256"
    jws = Jws.sign(%{alg: alg}, @payload, @hs256_key)
    {:ok, verified_jws} = Jws.verify(jws, alg, @hs256_key)
    assert verified_jws === String.split(jws, ".")
    plausible_jws?(jws)
  end

  test "sign/3 w/o passing a matching algorithm to verify/3 raises" do
    jws = Jws.sign(%{alg: "HS256"}, @payload, @hs256_key)
    assert {:error, JWT.UnmatchedAlgorithmError} == Jws.verify(jws, "RS256", @hs256_key)
  end

  test "sign/3 w/o passing a key to verify/3 is false" do
    alg = "HS256"
    jws = Jws.sign(%{alg: alg}, @payload, @hs256_key)
    assert {:error, JWT.MissingKeyError} == Jws.verify(jws, alg, nil)
  end

  defp plausible_unsecured_jws?(jws) do
    parts = String.split(jws, ".")
    assert length(parts) == 3
    [_, _, blank_part] = parts
    assert blank_part == ""
  end

  test "unsecured_message/2 does verify/3 and is plausible" do
    alg = "none"
    jws = Jws.unsecured_message(%{alg: alg}, @payload)
    # key is ignored
    {:ok, verified_jws} = Jws.verify(jws, alg, @hs256_key)
    assert verified_jws === String.split(jws, ".")
    plausible_unsecured_jws?(jws)
  end

  test "unsecured_message/2 w/o passing a valid header to verify/3 raises" do
    assert_raise FunctionClauseError, fn ->
      Jws.unsecured_message(%{alg: "HS256"}, @payload)
    end
  end

  test "unsecured_message/2 w/o passing a matching algorithm to verify/3 raises" do
    jws = Jws.unsecured_message(%{alg: "none"}, @payload)
    assert {:error, JWT.UnmatchedAlgorithmError} == Jws.verify(jws, "HS256", @hs256_key)
  end
end
