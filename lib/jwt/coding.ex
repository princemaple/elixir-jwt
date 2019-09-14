defmodule JWT.Coding do
  def encode!(map) do
    map
    |> Jason.encode!()
    |> Base.url_encode64(padding: false)
  end

  def decode!(binary, opts \\ []) do
    binary
    |> Base.url_decode64!(padding: false)
    |> Jason.decode!(opts)
  end

  def decode(binary, opts \\ []) do
    with {:ok, url_decoded} <- Base.url_decode64(binary, padding: false),
         {:ok, json_decoded} <- Jason.decode(url_decoded, opts),
         do: {:ok, json_decoded}
  end
end
