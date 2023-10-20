defmodule JWT.Claim.Iat do
  @moduledoc """
  Issued at

  see http://tools.ietf.org/html/rfc7519#section-4.1.6
  """

  @doc """
  Predicate to reject an issued_at time claim value equal to or after the current time

  ## Example
      iex> seconds = DateTime.to_unix(DateTime.utc_now) - 1
      ...> Iat.reject?(seconds, %{})
      false

  Returns `false` if the current time is after `numeric_date`; otherwise returns `true`

  `numeric_date` is the number of seconds from the Unix Epoch (1970-01-01T00:00:00Z UTC)
  until the specified UTC date/time; non-integer values may be used
  """
  def reject?(numeric_date, _) when is_number(numeric_date) do
    numeric_date > DateTime.to_unix(DateTime.utc_now())
  end

  def reject?(_, _), do: true
end
