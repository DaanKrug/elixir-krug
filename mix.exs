defmodule Krug.MixProject do
  use Mix.Project
  
  @project_url "https://github.com/DaanKrug/elixir-krug"

  def project do
    [
      app: :krug,
      version: "1.1.14",
      elixir: "~> 1.13",
      source_url: @project_url,
      homepage_url: @project_url,
      name: "Krug",
      description: "A Utilitary package functionalities modules for improve a secure performatic development.",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      package: package(),
      docs: [main: "readme", extras: ["README.md"]],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end


  defp deps do
    [
      {:earmark, "~> 1.4.13", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:bcrypt_elixir, "~> 2.2.0"},
      {:poison, "~> 4.0.1"},
      {:httpoison, "~> 1.7"},
      {:ex_aws, "~> 2.1.6"},
	  {:ex_aws_s3, "~> 2.0"},
	  {:bamboo, "~> 1.6.0"},
      {:bamboo_smtp, "~> 3.0.0"},
      {:bamboo_config_adapter, "~> 1.0.0"}
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
