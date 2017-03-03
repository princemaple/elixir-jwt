defmodule JWT.Algorithm.SHA do
  @moduledoc "Common algorithm sha_bits validation"

  @types [:sha256, :sha384, :sha512]

  @type_to_length %{
    :sha256 => 256,
    :sha384 => 384,
    :sha512 => 512
  }

  defmacro valid?(type), do: quote(do: unquote(type) in unquote(@types))

  def fetch_length!(type), do: Map.fetch!(@type_to_length, type)
end
