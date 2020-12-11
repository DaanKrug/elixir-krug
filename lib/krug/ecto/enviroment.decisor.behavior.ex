defmodule Krug.EctoEnviromentDecisor do

  @moduledoc """
  Defines a behaviour for higher-level Ecto enviroment changes decisor.
  Whit this is possible change a db connection from/to dev/pro
  in build time, if we use a .sh script for re-generate one 
  module that implements this.
  
  This module should be passed as ```decisor:``` value option
  on module that extends ```Krug.EnviromentReader``` 
  
  Utilization Example:
  ```elixir
  defmodule MyApp.EnviromentDecisor do

    @behaviour Krug.EctoEnviromentDecisor

    @impl Krug.EctoEnviromentDecisor
    def get_enviroment_type() do
      "dev"
    end

  end
  
  defmodule MyApp.Enviroment.Reader do

    use Krug.EnviromentReader, decisor: MyApp.EnviromentDecisor, enviroment: MyApp.Enviroment

  end
  ```
  """
  @moduledoc since: "0.2.1"
  
  
  
  @doc """
  Should return "dev" or "prod". All other values will generate problems.
  """
  @callback get_enviroment_type() :: String.t()
  
end