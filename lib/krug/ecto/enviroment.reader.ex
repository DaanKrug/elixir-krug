defmodule Krug.EnviromentReader do

  @moduledoc """
  Provides a mechanism to simplificate the Ecto db configuration on build time.
  
  Should be used whit a module that implements ```Krug.EctoEnviromentDecisor``` behavior
  and other module that implements ```Krug.EctoEnviroment``` behavior.
  
  Utilization Example:
  ```elixir
  defmodule MyApp.Enviroment.Reader do

    use Krug.EnviromentReader, decisor: MyApp.EnviromentDecisor, enviroment: MyApp.Enviroment

  end
  ```
  
  After maked this, we could use it to configure a Ecto Repo
  
  ```elixir
  defmodule MyApp.App.Repo do
  
    use Ecto.Repo, otp_app: :ex_app, adapter: Ecto.Adapters.MyXQL
    alias MyApp.Enviroment.Reader
	  
    def init(_type, config) do
      config = Keyword.put(config, :hostname,               Reader.read_key_value("APPDB_HOST"))
      config = Keyword.put(config, :port, String.to_integer(Reader.read_key_value("APPDB_PORT")))
      config = Keyword.put(config, :database,               Reader.read_key_value("APPDB_DATABASE"))
      config = Keyword.put(config, :username,               Reader.read_key_value("APPDB_USERNAME"))
      config = Keyword.put(config, :password,               Reader.read_key_value("APPDB_PASSWORD"))
      config = Keyword.put(config, :pool_size, 10)
      config = Keyword.put(config, :timeout, 60_000)
      config = Keyword.put(config, :ownership_timeout, 60_000)
      config = Keyword.put(config, :queue_target, 500)
      config = Keyword.put(config, :queue_interval, 10_000)
      {:ok, config}
    end
	  
  end
  ```
  """
  @moduledoc since: "0.2.1"
  
  
  
  defmacro __using__(opts) do
  
    quote bind_quoted: [opts: opts] do
     
      @decisor Keyword.get(opts,:decisor)
      @enviroment Keyword.get(opts,:enviroment)
      
      alias Krug.StructUtil
    
      def read_key_value(key) do
	    list = @decisor.get_enviroment_type() |> @enviroment.get_enviroment()
	    StructUtil.get_key_par_value_from_list(key,list)
	  end
	 
    end

  end
  
end