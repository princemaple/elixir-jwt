defmodule JWT.Jws do
  @moduledoc """
  Represent content to be secured with digital signatures or Message Authentication Codes (MACs)

  see http://tools.ietf.org/html/rfc7515
  """

  alias JWT.Jwa

  @doc """
  Return a JSON Web Signature (JWS), a string representing a digitally signed payload

  ## Example
      iex> key = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
      ...> JWT.Jws.sign(%{alg: "HS256"}, "payload", key)
      "eyJhbGciOiJIUzI1NiJ9.cGF5bG9hZA.uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"
  """
  @spec sign(map, binary, binary) :: binary
  def sign(%{alg: alg} = header, payload, key) do
    data = signing_input(header, payload)
    "#{data}.#{do_sign(alg, key, data)}"
  end

  @doc """
  Return a JWS that provides no integrity protection (i.e. lacks a signature)

  ## Example
      iex> JWT.Jws.unsecured_message(%{alg: "none"}, "payload")
      "eyJhbGciOiJub25lIn0.cGF5bG9hZA."

  see http://tools.ietf.org/html/rfc7515#page-47
  """
  def unsecured_message(%{alg: "none"} = header, payload) do
    signing_input(header, payload) <> "."
  end

  defp signing_input(header, payload) do
    "#{JWT.Coding.encode!(header)}.#{Base.url_encode64(payload, padding: false)}"
  end

  defp do_sign(algorithm, key, signing_input) do
    Jwa.sign(algorithm, key, signing_input)
    |> Base.url_encode64(padding: false)
  end

  @doc """
  Return a tuple {:ok, jws_parts} if the signature is verified, or {:error, exception} otherwise

  ## Example
      iex> jws = "eyJhbGciOiJIUzI1NiJ9.cGF5bG9hZA.uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"
      ...> key = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
      ...> JWT.Jws.verify(jws, "HS256", key)
      {:ok, ["eyJhbGciOiJIUzI1NiJ9", "cGF5bG9hZA", "uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"]}

      iex> jws = "eyJhbGciOiJIUzI1NiJ9.cGF5bG9hZA.uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"
      ...> key = "invalid-key-invalid-key-invalid-key"
      ...> JWT.Jws.verify(jws, "HS256", key)
      {:error, JWT.InvalidSignatureError}

      iex> jws = "eyJhbGciOiJIUzI1NiJ9.modified-content.uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"
      ...> key = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
      ...> JWT.Jws.verify(jws, "HS256", key)
      {:error, JWT.InvalidSignatureError}

      iex> jws = "eyJhb%%%%%%%%%%%%%%%.cGF5bG9hZA.uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"
      ...> key = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
      ...> JWT.Jws.verify(jws, "HS256", key)
      {:error, JWT.DecodeError}

      iex> jws = "eyJhbGciOiJIUzI1NiJ9.uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"
      ...> key = nil
      ...> JWT.Jws.verify(jws, "HS256", key)
      {:error, JWT.MissingKeyError}

      iex> jws = "eyJhbGciOiJIUzI1NiJ9.cGF5bG9hZA.uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"
      ...> key = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
      ...> JWT.Jws.verify(jws, "%%%%%", key)
      {:error, JWT.UnmatchedAlgorithmError}
  """
  @spec verify(binary, binary, binary) :: {:ok, [binary]} | {:error, atom}
  def verify(jws, algorithm, key) do
    with [header | _] = jws_parts <- String.split(jws, "."),
         :ok <- validate_alg(header, algorithm),
         :ok <- verify_signature(jws_parts, algorithm, key) do
      {:ok, jws_parts}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Return jws parts if the signature is verified, raises error otherwise

  ## Example
      iex> jws = "eyJhbGciOiJIUzI1NiJ9.cGF5bG9hZA.uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"
      ...> key = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
      ...> JWT.Jws.verify!(jws, "HS256", key)
      ["eyJhbGciOiJIUzI1NiJ9", "cGF5bG9hZA", "uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"]

      iex> jws = "eyJhbGciOiJIUzI1NiJ9.cGF5bG9hZA.uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"
      ...> key = "invalid-key-invalid-key-invalid-key"
      ...> JWT.Jws.verify!(jws, "HS256", key)
      ** (JWT.InvalidSignatureError) Invalid Signature

      iex> jws = "eyJhbGciOiJIUzI1NiJ9.modified-content.uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"
      ...> key = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
      ...> JWT.Jws.verify!(jws, "HS256", key)
      ** (JWT.InvalidSignatureError) Invalid Signature

      iex> jws = "eyJhb%%%%%%%%%%%%%%%.cGF5bG9hZA.uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"
      ...> key = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
      ...> JWT.Jws.verify!(jws, "HS256", key)
      ** (JWT.DecodeError) Failed to decode base64 string

      iex> jws = "eyJhbGciOiJIUzI1NiJ9.uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"
      ...> key = nil
      ...> JWT.Jws.verify!(jws, "HS256", key)
      ** (JWT.MissingKeyError) Key is required for all algorithms but 'none'

      iex> jws = "eyJhbGciOiJIUzI1NiJ9.cGF5bG9hZA.uVTaOdyzp_f4mT_hfzU8LnCzdmlVC4t2itHDEYUZym4"
      ...> key = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
      ...> JWT.Jws.verify!(jws, "%%%%%", key)
      ** (JWT.UnmatchedAlgorithmError) Algorithm not matching 'alg' header parameter
  """
  @spec verify!(binary, binary, binary) :: [binary] | no_return
  def verify!(jws, algorithm, key) do
    case verify(jws, algorithm, key) do
      {:ok, jws_parts} ->
        jws_parts

      {:error, error} ->
        raise error
    end
  end

  defp validate_alg(header, algorithm) do
    with {:ok, header} <- JWT.Coding.decode(header) do
      if header["alg"] == algorithm, do: :ok, else: {:error, JWT.UnmatchedAlgorithmError}
    end
  end

  defp verify_signature(_jws_parts, "none", _key), do: :ok
  defp verify_signature(_jws_parts, _algorithm, nil), do: {:error, JWT.MissingKeyError}

  defp verify_signature([header, message, signature], algorithm, key) do
    verified =
      signature
      |> Base.url_decode64!(padding: false)
      |> Jwa.verify?(algorithm, key, "#{header}.#{message}")

    if verified, do: :ok, else: {:error, JWT.InvalidSignatureError}
  end

  defp verify_signature(_jws_parts, _algorithm, _key), do: {:error, JWT.InvalidSignatureError}
end
