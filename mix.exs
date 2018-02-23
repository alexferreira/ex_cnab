defmodule ExCnab.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_cnab,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env),
      test_coverage: [tool: ExCoveralls],
      deps: deps()
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test"]
  def elixirc_paths(:dev), do: ["lib", "test"]
  def elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExCnab.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:excoveralls, "~> 0.6", only: [:dev, :test]},
      {:faker_elixir_octopus, "~> 1.0.0",  only: [:dev, :test]}
    ]
  end
end
