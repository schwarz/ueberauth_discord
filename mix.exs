defmodule UeberauthDiscord.Mixfile do
  use Mix.Project

  @version "0.7.0"
  @url "https://github.com/schwarz/ueberauth_discord"

  def project do
    [
      app: :ueberauth_discord,
      version: @version,
      elixir: "~> 1.3",
      name: "Ueberauth Discord",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: @url,
      homepage_url: @url,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [applications: [:logger, :oauth2, :ueberauth]]
  end

  defp deps do
    [
      {:ueberauth, "~> 0.10"},
      {:oauth2, "~> 1.0 or ~> 2.0"},
      {:ex_doc, "~> 0.27", only: :dev},
      {:earmark, ">= 0.0.0", only: :dev}
    ]
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp description do
    "An Uberauth strategy for Discord authentication."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Bernhard Schwarz"],
      licenses: ["MIT"],
      links: %{GitHub: @url}
    ]
  end
end
