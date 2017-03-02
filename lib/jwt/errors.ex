defmodule JWT.UnmatchedAlgorithmError do
  defexception message: "Algorithm not matching 'alg' header parameter"
end

defmodule JWT.InvalidSignatureError do
  defexception message: "Invalid Signature"
end

defmodule JWT.MissingKeyError do
  defexception message: "Key is required for all algorithms but 'none'"
end
