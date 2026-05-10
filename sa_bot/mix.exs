defmodule SaBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :sa_bot,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :nostrum],
      mod: {SaBot, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.10"},
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.4"},
      {:hackney, "~> 1.17"},
      {:dotenv, "~> 3.0"}
    ]
  end
end
