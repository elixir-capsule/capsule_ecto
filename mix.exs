defmodule CapsuleEcto.MixProject do
  use Mix.Project

  def project do
    [
      app: :capsule_ecto,
      version: "0.2.1",
      description: "Ecto integration for Capsule",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "CapsuleEcto",
      source_url: "https://github.com/elixir-capsule/capsule_ecto",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:capsule, "~> 0.2"},
      {:ecto, "~> 3.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      maintainers: ["Thomas Floyd Wright"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/elixir-capsule/capsule_ecto"}
    ]
  end
end
