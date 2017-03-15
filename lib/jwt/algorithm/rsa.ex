defmodule JWT.Algorithm.Rsa do
  @moduledoc """
  Sign or verify a JSON Web Signature (JWS) structure using RSASSA-PKCS-v1_5

  see http://tools.ietf.org/html/rfc7518#section-3.3
  """

  require JWT.Algorithm.SHA, as: SHA

  @key_bits_min 2048

  @doc """
  Return a Message Authentication Code (MAC)

  ## Example
      iex> alias JWT.Algorithm.RsaUtil
      ...> private_key = RsaUtil.private_key("test/fixtures/rsa", "private_key.pem")
      ...> mac = JWT.Algorithm.Rsa.sign(:sha256, private_key, "signing_input")
      ...> byte_size(mac)
      256
  """
  def sign(sha_bits, private_key, signing_input) when SHA.valid?(sha_bits) do
    validate_key_size!(private_key)
    :crypto.sign(:rsa, sha_bits, signing_input, private_key)
  end

  @doc """
  Predicate to verify a digital signature, or mac

  ## Example
      iex> alias JWT.Algorithm.RsaUtil
      ...> path_to_keys = "test/fixtures/rsa"
      ...> private_key = RsaUtil.private_key(path_to_keys, "private_key.pem")
      ...> public_key = RsaUtil.public_key(path_to_keys, "public_key.pem")
      ...> mac = JWT.Algorithm.Rsa.sign(:sha256, private_key, "signing_input")
      ...> JWT.Algorithm.Rsa.verify?(mac, :sha256, public_key, "signing_input")
      true
  """
  def verify?(mac, sha_bits, public_key, signing_input) when SHA.valid?(sha_bits) do
    validate_key_size!(public_key)
    :crypto.verify(:rsa, sha_bits, signing_input, mac, public_key)
  end

  @doc "RSA key modulus, n"
  def modulus([_e, n | d]), do: :binary.encode_unsigned(n)

  # http://tools.ietf.org/html/rfc7518#section-3.3
  defp validate_key_size!(key) do
    key_size = length(for(<<bit::1 <- modulus(key)>>, do: bit))

    if key_size < @key_bits_min do
      raise JWT.SecurityError,
        type: :rsa, message: "RSA modulus too short"
    end
  end
end
