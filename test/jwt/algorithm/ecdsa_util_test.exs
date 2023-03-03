defmodule JWT.Algorithm.EcdsaUtilTest do
  use ExUnit.Case

  alias JWT.Algorithm.EcdsaUtil

  test "key_pair/1 default :secp256r1" do
    {public_key, private_key} = EcdsaUtil.key_pair()
    assert is_binary(public_key)
    assert is_binary(private_key)
    assert byte_size(public_key) == 65
    assert byte_size(private_key) > 30
  end

  test "key_pair/1 for :secp384r1" do
    {public_key, private_key} = EcdsaUtil.key_pair(:sha384)
    assert is_binary(public_key)
    assert is_binary(private_key)
    assert byte_size(public_key) == 97
    assert byte_size(private_key) > 47
  end

  test "key_pair/1 for :secp521r1" do
    {public_key, private_key} = EcdsaUtil.key_pair(:sha512)
    assert is_binary(public_key)
    assert is_binary(private_key)
    assert byte_size(public_key) == 133
    assert byte_size(private_key) > 63
  end
end
