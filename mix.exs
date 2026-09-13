defmodule Krug.MixProject do
  use Mix.Project
  
  @project_url "https://github.com/DaanKrug/elixir-krug"

  def project do
    [
      app: :krug,
      version: "3.0.0",
      elixir: "~> 1.20",
      source_url: @project_url,
      homepage_url: @project_url,
      name: "Krug",
      description: "A Utilitary package functionalities modules for improve a secure performatic development.",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      package: package(),
      docs: [main: "readme", extras: ["README.md"]],
      deps: deps(),
      elixirc_options: [
        no_warn_undefined: [
          :mnesia
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger,:mnesia]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false},
      {:sobelow, "~> 0.15", only: [:dev, :test], runtime: false},
      {:bcrypt_elixir, "~> 3.3"},
      {:poison, "~> 6.0"},
      {:httpoison, "~> 3.0"},
      {:ex_aws, "~> 2.7"},
      {:ex_aws_s3, "~> 2.5"},
      {:bamboo, "~> 2.2"},
      {:bamboo_smtp, "~> 4.2"},
      #  {:bamboo_config_adapter, "~> 1.1"},
      {:gen_smtp, "~> 1.3", override: true}
    ]
  end
  
  defp aliases do
    [c: "compile", d: "docs"]
  end
  
  defp package do
    [
      maintainers: ["Daniel Augusto Krug @daankrug <daniel-krug@hotmail.com>"],
      licenses: ["MIT"],
      links: %{"GitHub" => @project_url}
    ]
  end
  
end
