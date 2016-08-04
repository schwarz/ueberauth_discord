defmodule UeberauthDiscord.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/schwarz/ueberauth_discord"

  def project do
    [app: :ueberauth_discord,
     version: @version,
     elixir: "~> 1.3",
     name: "Ueberauth Discord",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: @url,
     homepage_url: @url,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :oauth2, :ueberauth]]
  end

  defp deps do
    [{:ueberauth, "~> 0.3"},
     {:oauth2, "~> 0.5"}]
  end
end
