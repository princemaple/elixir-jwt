defmodule JWT.Claim.Sub do
  @moduledoc """
  Subject

  see http://tools.ietf.org/html/rfc7519#section-4.1.2
  """

  @doc """
  Predicate to reject a sub claim that does not match the expected subject

  ## Example
      iex> Sub.reject?("subject", %{sub: "other subject"})
      true

  Returns `true` or `false`
  """
  def reject?(sub, %{sub: sub}), do: false
  def reject?(_, _), do: true
end
