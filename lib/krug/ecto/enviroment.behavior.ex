defmodule Krug.EctoEnviroment do

  @moduledoc """
  Defines a behaviour for higher-level Ecto enviroments key values.
  
  The module that implement this, should be passed as ```enviroment:``` value option
  on module that extends ```Krug.EnviromentReader``` 
  
  Utilization Example:
  ```elixir
  defmodule MyApp.Enviroment do

    @behaviour Krug.EctoEnviroment

    @impl Krug.EctoEnviroment
    def get_enviroment(type) do
      cond do
        (type == "prod") -> get_enviroment_list_prod()
        true -> get_enviroment_list_dev()
      end
    end

  end
  
  defmodule MyApp.Enviroment.Reader do

    use Krug.EnviromentReader, decisor: MyApp.EnviromentDecisor, enviroment: MyApp.Enviroment

  end
  ```
  """
  @moduledoc since: "0.2.1"
  
  
  
  @doc """
  Should return an array of strings, based on value received ("dev" or "prod") 
  containing key pars values based on schema: "key=value".
  
  -Example:
  ```elixir
  defmodule MyApp.Enviroment do

    @behaviour Krug.EctoEnviroment

    @impl Krug.EctoEnviroment
    def get_enviroment(type) do
      cond do
        (type == "prod") -> get_enviroment_list_prod()
        true -> get_enviroment_list_dev()
      end
    end
	
    defp get_enviroment_list_dev() do
      ["APPDB_HOST=127.0.0.1","APPDB_PORT=3306","APPDB_DATABASE=elixir_app_db_development",
	   "APPDB_USERNAME=root","APPDB_PASSWORD=123456"]
    end
	
    defp get_enviroment_list_prod() do
      ["APPDB_HOST=127.0.0.1","APPDB_PORT=3306","APPDB_DATABASE=elixir_app_db_production",
	   "APPDB_USERNAME=root","APPDB_PASSWORD=123456"]
    end

  end
  
  """
  @callback get_enviroment(type :: String.t()) :: [String.t()]
  
end