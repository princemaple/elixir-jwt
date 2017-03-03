defmodule JWT.Coding do
  def encode!(map) do
    map
    |> Poison.encode!
    |> Base.url_encode64(padding: false)
  end

  def decode!(binary, opts \\ []) do
    binary
    |> Base.url_decode64!(padding: false)
    |> Poison.decode!(opts)
  end
end
