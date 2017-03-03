defmodule JWT.Claim.Iss do
  @moduledoc """
  Issuer

  see http://tools.ietf.org/html/rfc7519#section-4.1.1
  """

  @doc """
  Predicate to reject an iss claim that does not match the expected issuer

  ## Example
      iex> Iss.reject?("issuer", %{iss: "other issuer"})
      true

  Returns `true` or `false`
  """
  def reject?(iss, %{iss: iss}), do: false
  def reject?(_, _), do: true
end
