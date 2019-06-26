defmodule Agala.Provider.Vk.Mixfile do
  use Mix.Project

  def project do
    [
      app: :agala_vk,
      version: "3.0.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
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
      {:agala, "~> 3.0"},
      {:httpoison, "~> 1.2"},
      {:jason, "~> 1.1"},
      {:ex_doc, "~> 0.16", only: :dev},
      {:inch_ex, "~> 2.0", only: :docs},
      {:credo, "~> 1.1", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    Vk provider for Agala framework.
    """
  end

  defp package do
    [
      maintainers: ["Dmitry Rubinstein"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/agalaframework/agala_vk"},
      files: ~w(mix.exs README* CHANGELOG* lib)
    ]
  end
end
