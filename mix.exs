defmodule Jwt.Mixfile do
  use Mix.Project

  @version "1.4.2"

  def project do
    [
      app: :yajwt,
      version: @version,
      elixir: "~> 1.13",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: "Yet another JWT lib",
      deps: deps(),
      package: package(),
      docs: [
        source_ref: "v#{@version}",
        main: "JWT",
        canonical: "http://hexdocs.pm/yajwt",
        source_url: "https://github.com/princemaple/elixir-jwt"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:crypto, :logger, :public_key],
      env: [json_library: Jason]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :docs}
    ]
  end

  defp package do
    [
      maintainers: ["Po Chen"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/princemaple/elixir-jwt"}
    ]
  end
end
