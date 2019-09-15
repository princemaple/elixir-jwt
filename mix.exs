defmodule Jwt.Mixfile do
  use Mix.Project

  @version "1.2.1"

  def project do
    [
      app: :yajwt,
      version: @version,
      elixir: "~> 1.6",
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
    [extra_applications: [:crypto, :logger, :public_key]]
  end

  defp deps do
    [
      {:jason, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
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
