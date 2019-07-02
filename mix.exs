defmodule Agala.Provider.Vk.Mixfile do
  use Mix.Project

  def project do
    [
      app: :agala_vk,
      version: "2.5.0",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :agala]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:agala, github: "IT-CTI/agala", branch: "2.5"},
      {:httpoison, "~> 1.1"},
      {:poison, ">= 1.5.0"},
      {:ex_doc, "~> 0.16", only: :dev},
      {:inch_ex,"~> 0.5", only: :docs},
      {:credo, "~> 0.8", only: [:dev, :test]}
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
