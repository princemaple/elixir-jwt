defmodule JWT.Claim.Aud do
  @moduledoc """
  Audience

  see http://tools.ietf.org/html/rfc7519#section-4.1.3
  """

  @doc """
  Predicate to reject an audience claim value that does not include the recipient

  ## Example
      iex> recipient = "recipient"
      ...> aud = [recipient]
      ...> Aud.reject?(aud, %{aud: recipient})
      false

  Returns `true` or `false`
  """
  def reject?(aud, options) do
    Map.get(options, :aud) not in List.wrap(aud)
  end
end
