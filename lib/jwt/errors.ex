defmodule JWT.UnmatchedAlgorithmError do
  defexception message: "Algorithm not matching 'alg' header parameter"
end

defmodule JWT.InvalidSignatureError do
  defexception message: "Invalid Signature"
end

defmodule JWT.MissingKeyError do
  defexception message: "Key is required for all algorithms but 'none'"
end

defmodule JWT.DecodeError do
  defexception message: "Failed to decode base64 string"
end

defmodule JWT.ClaimValidationError do
  defexception claims: [], message: "Failed JWT claim validation"
end

defmodule JWT.SecurityError do
  defexception [:type, :message]
end
