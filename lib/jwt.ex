defmodule JWT do
  @moduledoc """
  Encode claims for transmission as a JSON object that is used as the payload of a JSON Web
  Signature (JWS) structure, enabling the claims to be integrity protected with a Message
  Authentication Code (MAC), to be later verified

  see http://tools.ietf.org/html/rfc7519
  """

  alias JWT.Jws

  @default_algorithm "HS256"
  @default_header %{typ: "JWT"}
  # JOSE header types from: https://tools.ietf.org/html/rfc7515
  @header_jose_keys [:alg, :jku, :jwk, :kid, :x5u, :x5c, :x5t, :"x5t#S256", :typ, :cty, :crit]

  @doc """
  Return a JSON Web Token (JWT), a string representing a set of claims as a JSON object that is
  encoded in a JWS

  ## Example
      iex> claims = %{iss: "joe", exp: 1300819380, "http://example.com/is_root": true}
      ...> key = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
      ...> JWT.sign(claims, key: key)
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjEzMDA4MTkzODAsImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlLCJpc3MiOiJqb2UifQ.C5kby-t7W1CM1VB_avPCCHbtOXsNsywYAKYex8rHZh8"

  see http://tools.ietf.org/html/rfc7519#section-7.1
  """
  @spec sign(map, Keyword.t() | map) :: binary
  def sign(claims, options) when is_map(claims) do
    header = unify_header(options)
    jws_message(header, Jason.encode!(claims), options[:key])
  end

  defp jws_message(%{alg: "none"} = header, payload, _key) do
    Jws.unsecured_message(header, payload)
  end

  defp jws_message(header, payload, key) do
    Jws.sign(header, payload, key)
  end

  @doc """
  Given an options map, return a map of header options

  ## Example
      iex> JWT.unify_header(alg: "RS256", key: "key")
      %{typ: "JWT", alg: "RS256"}

  Filters out unsupported claims options and ignores any encryption keys
  """
  @spec unify_header(Keyword.t() | map) :: map
  def unify_header(options) when is_list(options) do
    options |> Map.new() |> unify_header
  end

  def unify_header(options) when is_map(options) do
    jose_registered_headers = Map.take(options, @header_jose_keys)

    @default_header
    |> Map.merge(jose_registered_headers)
    |> Map.merge(%{alg: algorithm(options)})
  end

  @doc """
  Return a tuple {:ok, claims (map)} if the JWT signature is verified,
  or {:error, "invalid"} otherwise

  ## Example
      iex> jwt ="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuYW1lIjoiam9lIiwiaHR0cDovL2V4YW1wbGUuY29tL2lzX3Jvb3QiOnRydWUsImRhdGV0aW1lIjoxMzAwODE5MzgwfQ.8CbXtOJ51MfPLlNTDpMMBHExFZGmqIC2c_hjuY0Dp24"
      ...> key = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
      ...> JWT.verify(jwt, %{key: key})
      {:ok, %{"name" => "joe", "datetime" => 1300819380, "http://example.com/is_root" => true}}

  see http://tools.ietf.org/html/rfc7519#section-7.2
  """
  @spec verify(binary, map) :: {:ok, map} | {:error, Keyword.t()}
  def verify(jwt, options) do
    with {:ok, [_, payload, _]} <- Jws.verify(jwt, algorithm(options), options[:key]),
         {:ok, claims} <- JWT.Coding.decode(payload),
         :ok <- JWT.Claim.verify(claims, options) do
      {:ok, claims}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @spec verify!(binary, map) :: map | no_return
  def verify!(jwt, options) do
    [_, payload, _] = Jws.verify!(jwt, algorithm(options), options[:key])
    claims = JWT.Coding.decode!(payload)

    with :ok <- JWT.Claim.verify(claims, options) do
      claims
    else
      {:error, rejected_claims} ->
        raise JWT.ClaimValidationError, claims: rejected_claims
    end
  end

  defp algorithm(options) do
    Map.get(options, :alg, @default_algorithm)
  end
end
