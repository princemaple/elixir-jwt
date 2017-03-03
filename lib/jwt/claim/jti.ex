defmodule JWT.Claim.Jti do
  @moduledoc """
  JWT ID

  see http://tools.ietf.org/html/rfc7519#section-4.1.7
  """

  @doc """
  Predicate to reject a jti claim that does not match the expected JTI

  ## Example
      iex> Jti.reject?("jwt_id", %{iss: "other jwt_id"})
      true

  Returns `true` or `false`
  """
  def reject?(jti, %{jti: jti}), do: false
  def reject?(_, _), do: true
end
