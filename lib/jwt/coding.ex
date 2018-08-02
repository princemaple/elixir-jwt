defmodule JWT.Coding do
  def encode!(map) do
    map
    |> Jason.encode!
    |> Base.url_encode64(padding: false)
  end

  def decode!(binary, opts \\ []) do
    binary
    |> Base.url_decode64!(padding: false)
    |> Jason.decode!(opts)
  end
end
