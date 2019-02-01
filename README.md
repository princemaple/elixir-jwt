# Yet another JWT lib for Elixir

This is a rewrite of [json_web_token_ex](https://github.com/garyf/json_web_token_ex)
with [jwt_claims_ex](https://github.com/garyf/jwt_claims_ex) merged in,
both created by [@garyf](https://github.com/garyf).

Many things were simplified during the rewrite, code was cleaned up as well.

## Installation

The package can be installed by adding `yajwt` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:yajwt, "~> 1.0"}]
end
```

## Usage

### JWT.sign(claims, options)

Returns a JSON Web Token string

`claims` (required) map

`options` (required) map

* **alg** (optional, default: `"HS256"`)
* **key** (required unless alg is "none")

Include any JWS JOSE header parameters ([RFC 7515][rfc7515]) in the options map

Example

```elixir

# sign with default algorithm, HMAC SHA256
jwt = JWT.sign(%{foo: "bar"}, %{key: "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"})

# sign with RSA SHA256 algorithm
private_key = JWT.Algorithm.RsaUtil.private_key("path/to/", "key.pem")
opts = %{
  alg: "RS256",
  key: private_key
}

jwt = JWT.sign(%{foo: "bar"}, opts)

# unsecured token (algorithm is "none")
jwt = JWT.sign(%{foo: "bar"}, %{alg: "none"})

```

### JWT.verify(jwt, options)

Returns a tuple, either:
* \{:ok, claims\}, a JWT claims set map, if the Message Authentication Code (MAC), or signature, is verified
* \{:error, "invalid"\}, otherwise

`"jwt"` (required) is a JSON web token string

`options` (required) map

* **alg** (optional, default: `"HS256"`)
* **key** (required unless alg is "none")

Example

```elixir

secure_jwt_example = "eyJ0eXAiOiJKV1QiLA0KICJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0dHA6Ly9leGFt.cGxlLmNvbS9pc19yb290Ijp0cnVlfQ.dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"

# verify with default algorithm, HMAC SHA256
{:ok, claims} = JWT.verify(secure_jwt_example, %{key: "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"})

# Or with the bang version
claims = JWT.verify!(secure_jwt_example, %{key: "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"})

# verify with RSA SHA256 algorithm
opts = %{
  alg: "RS256",
  key: < RSA public key >
}

{:ok, claims} = JWT.verify(jwt, opts)

# unsecured token (algorithm is "none")
unsecured_jwt_example = "eyJ0eXAiOiJKV1QiLA0KICJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0dHA6Ly9leGFt."

{:ok, claims} = JWT.verify(unsecured_jwt_example, %{alg: "none"})

```

### Supported encryption algorithms

alg Param Value | Digital Signature or MAC Algorithm
------|------
HS256 | HMAC using SHA-256 per [RFC 2104][rfc2104]
HS384 | HMAC using SHA-384
HS512 | HMAC using SHA-512
RS256 | RSASSA-PKCS-v1_5 using SHA-256 per [RFC3447][rfc3447]
RS384 | RSASSA-PKCS-v1_5 using SHA-384
RS512 | RSASSA-PKCS-v1_5 using SHA-512
ES256 | ECDSA using P-256 and SHA-256 per [DSS][dss]
ES384 | ECDSA using P-384 and SHA-384
ES512 | ECDSA using P-521 and SHA-512
none | No digital signature or MAC performed (unsecured)

### Registered claim names

The following claims are supported. They are validated when the JWT is verified.
* **iss** (Issuer)
* **sub** (Subject)
* **aud** (Audience)
* **exp** (Expiration Time)
* **nbf** (Not Before)
* **iat** (Issued At)
* **jti** (JWT ID)

[rfc2104]: http://tools.ietf.org/html/rfc2104
[rfc3447]: http://tools.ietf.org/html/rfc3447
[rfc7515]: http://tools.ietf.org/html/rfc7515
[rfc7516]: http://tools.ietf.org/html/rfc7516
[rfc7518]: http://tools.ietf.org/html/rfc7518
[rfc7519]: http://tools.ietf.org/html/rfc7519
[dss]: http://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-4.pdf

[thomson-postel]: https://tools.ietf.org/html/draft-thomson-postel-was-wrong-00

[travis]: https://travis-ci.org/garyf/json_web_token_ex
[ci_img]: https://travis-ci.org/garyf/json_web_token_ex.svg?branch=master
[hex_docs]: http://hexdocs.pm/json_web_token
[hd_img]: http://img.shields.io/badge/docs-hexpm-blue.svg

[jwt_claims]: https://github.com/garyf/jwt_claims_ex
