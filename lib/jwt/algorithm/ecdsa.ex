defmodule JWT.Algorithm.Ecdsa do
  @moduledoc """
  Sign or verify a JSON Web Signature (JWS) structure using EDCSA

  see http://tools.ietf.org/html/rfc7518#section-3.4
  """

  require JWT.Algorithm.SHA, as: SHA

  # attr: {curve, der_byte_count_minimum_threshold}
  @sha_bits_to_attr %{
    sha256: {:secp256k1, 69},
    sha384: {:secp384r1, 101},
    sha512: {:secp521r1, 137}
  }

  @doc """
  Return a der-encoded digital signature, or Message Authentication Code (MAC)

  ## Example
      iex> {_, private_key} = EcdsaUtil.key_pair
      ...> der_encoded_mac = JWT.Algorithm.Ecdsa.sign(:sha256, private_key, "signing_input")
      ...> byte_size(der_encoded_mac) > 69
      true
  """
  def sign(sha_bits, private_key, signing_input) when SHA.valid?(sha_bits) do
    mac = :crypto.sign(:ecdsa, sha_bits, signing_input, [private_key, curve(sha_bits)])
    validate_signature_size(mac, sha_bits)
  end

  @doc "Named curve corresponding to sha_bits"
  def curve(sha_bits) do
    {curve, _} = @sha_bits_to_attr[sha_bits]
    curve
  end

  @doc """
  Predicate to verify a der-encoded digital signature, or Message Authentication Code (MAC)

  ## Example
      iex> {public_key, private_key} = JWT.Algorithm.EcdsaUtil.key_pair
      ...> mac = JWT.Algorithm.Ecdsa.sign(:sha256, private_key, "signing_input")
      ...> JWT.Algorithm.Ecdsa.verify?(mac, :sha256, public_key, "signing_input")
      true
  """
  def verify?(mac, sha_bits, public_key, signing_input) when SHA.valid?(sha_bits) do
    validate_signature_size(mac, sha_bits)
    :crypto.verify(:ecdsa, sha_bits, signing_input, mac, [public_key, curve(sha_bits)])
  end

  # der encoding adds at least 6 bytes to the mac
  defp validate_signature_size(der_encoded_mac, sha_bits) do
    {_, der_byte_count_minimum_threshold} = @sha_bits_to_attr[sha_bits]

    if byte_size(der_encoded_mac) < der_byte_count_minimum_threshold do
      raise JWT.SecurityError,
        type: :ecdsa, message: "MAC too short"
    end

    der_encoded_mac
  end
end
