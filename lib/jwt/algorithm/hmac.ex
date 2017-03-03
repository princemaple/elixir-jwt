defmodule JWT.Algorithm.Hmac do
  @moduledoc """
  Sign or verify a JSON Web Signature (JWS) structure using HMAC with SHA-2 algorithms

  see http://tools.ietf.org/html/rfc7518#section-3.2
  """

  require JWT.Algorithm.SHA, as: SHA

  @doc """
  Return a Message Authentication Code (MAC)

  ## Example
      iex> shared_key = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
      ...> JWT.Algorithm.Hmac.sign(:sha256, shared_key, "signing_input")
      <<90, 34, 44, 252, 147, 130, 167, 173, 86, 191, 247, 93, 94, 12, 200, 30, 173, 115, 248, 89, 246, 222, 4, 213, 119, 74, 70, 20, 231, 194, 104, 103>>
  """
  def sign(sha_bits, shared_key, signing_input) when SHA.valid?(sha_bits) do
    validate_key_size!(sha_bits, shared_key)
    :crypto.hmac(sha_bits, shared_key, signing_input)
  end

  # http://tools.ietf.org/html/rfc7518#section-3.2
  defp validate_key_size!(sha_bits, key) do
    bits = SHA.fetch_length!(sha_bits)

    if byte_size(key) * 8 < bits do
      raise JWT.SecurityError,
        type: :hmac, message: "Key size smaller than the hash output size"
    end
  end

  @doc """
  Predicate to verify the signing_input by comparing a given `mac` to the `mac` for a newly
  signed message; comparison done in a constant-time manner to thwart timing attacks

  ## Example
      iex> mac = <<90, 34, 44, 252, 147, 130, 167, 173, 86, 191, 247, 93, 94, 12, 200, 30, 173, 115, 248, 89, 246, 222, 4, 213, 119, 74, 70, 20, 231, 194, 104, 103>>
      ...> shared_key = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
      ...> JWT.Algorithm.Hmac.verify?(mac, :sha256, shared_key, "signing_input")
      true
  """
  def verify?(mac, sha_bits, shared_key, signing_input) when SHA.valid?(sha_bits) do
    mac_match?(mac, sign(sha_bits, shared_key, signing_input))
  end

  # compares two strings for equality in constant-time to avoid timing attacks
  defp mac_match?(expected, actual) do
    byte_size(expected) == byte_size(actual) &&
      arithmetic_compare(expected, actual) == 0
  end

  defp arithmetic_compare(left, right, acc \\ 0)
  defp arithmetic_compare(<<x, left::binary>>, <<y, right::binary>>, acc) do
    import Bitwise
    arithmetic_compare(left, right, acc ||| (x ^^^ y))
  end
  defp arithmetic_compare("", "", acc), do: acc
end
