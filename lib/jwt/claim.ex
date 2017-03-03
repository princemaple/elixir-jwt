defmodule JWT.Claim do
  @moduledoc """
  Verify JSON Web Token (JWT) claims

  see http://tools.ietf.org/html/rfc7519#section-4.1
  """

  @registered_claims [:aud, :exp, :iat, :iss, :jti, :nbf, :sub]

  @doc """
  Collect JWT claims that fail validation

  ## Example
      iex> seconds = DateTime.to_unix(DateTime.utc_now) + 1
      ...> claims = %{"exp" => seconds}
      ...> JWT.Claim.verify(claims, %{})
      :ok

      iex> claims = %{"aud" => "Someone else"}
      ...> JWT.Claim.verify(claims, %{aud: "You"})
      {:error, [aud: "Someone else"]}

  Returns a list containing any registered claims that fail validation
  """
  @spec verify(map, map) :: [atom]
  def verify(claims, options) do
    @registered_claims
    |> Enum.reduce([], fn claim, rejected ->
      with {:ok, value} <- Map.fetch(claims, to_string(claim)) do
        if apply(claim_module(claim), :reject?, [value, options]) do
          [{claim, value} | rejected]
        else
          rejected
        end
      else
        :error -> rejected
      end
    end)
    |> format_result
  end

  defp format_result([]), do: :ok
  defp format_result(rejected_claims), do: {:error, rejected_claims}

  for claim <- @registered_claims do
    base_name = claim |> Atom.to_string |> Macro.camelize
    full_name = Module.concat(JWT.Claim, base_name)
    defp claim_module(unquote(claim)), do: unquote(full_name)
  end
end
