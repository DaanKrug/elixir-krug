defmodule Krug.DistributedMnesiaSqlCache do
 
  @moduledoc """
  Utilitary module to handle Erlang Mnesia Database.
  Mnesia Database has single instance mode and also distributed mode
  that is purpose of this module. Single instance way don't allow us
  to improve horizontal scalability when we need.
  """
  @moduledoc since: "1.1.17"
  
  
  
  alias Krug.DistributedMnesia
  alias Krug.MnesiaUtil
  
  
  
  @doc """
  Start the mnesia cluster. To be used on application start.
  
  ## Example
  
  ```elixir
  defmodule <Your_App_Main_Module_Name>.Application do
  
    @moduledoc false
  
    use Application
  
    alias Krug.DistributedMnesiaSqlCache


    def start(_type, _args) do
      Supervisor.start_link(children(), opts())
    end
  
    defp children() do
  	  [
  	    ...
  	    <Your_App_Main_Module_Name>.DistributedMnesiaSqlCacheTaskStarter, # calls Krug.DistributedMnesiaSqlCache.init_cluster(...)
  	    ...
  	  ]
    end
  
    defp opts() do 
  	  [strategy: :one_for_one, name: <Your_App_Main_Module_Name>.Supervisor]
    end 
    
  end
  ```
  
  ```elixir
  defmodule <Your_App_Main_Module_Name>.DistributedMnesiaSqlCacheConfigTaskStarter do
    def child_spec(opts) do
      %{id: __MODULE__,start: {__MODULE__, :start_link, [opts]}}
    end
  
    def start_link(opts) do
      Supervisor.start_link([{<Your_App_Main_Module_Name>.DistributedMnesiaSqlCacheConfigTask,opts}], strategy: :one_for_one)
    end
  end
  ```
  
  ```elixir
  defmodule <Your_App_Main_Module_Name>.DistributedMnesiaSqlCacheConfigTask do
 
    use Task
    alias Krug.DistributedMnesiaSqlCache
 
    def start_link(opts) do
      Task.start_link(__MODULE__, :run, [opts])
    end

    def run(_opts) do
      cluster_cookie = "echo"
      cluster_name = "echo"
      cluster_ips = "192.168.1.12X "
      ips_separator = "X" 
      table_names = [
        :users,
        :log,
        :other_table
      ]  
    
      cluster_name
        |> DistributedMnesiaSqlCache.init_cluster(cluster_cookie,cluster_ips,ips_separator,true,table_names)
    end
  
  end
  ```
  """
  def init_cluster(cluster_name,cluster_cookie,cluster_ips,
                   ips_separator \\ "|",disc_copies \\ false,table_names \\ [],
                   connection_timeout \\ nil) do
    tables = table_names 
               |> prepare_tables()
    cluster_name
      |> DistributedMnesia.init_cluster(
           cluster_cookie,
           cluster_ips,
           ips_separator,
           disc_copies,
           tables,
           connection_timeout
         ) 
  end
  
  
  
  @doc """
  Almost the same that "init_cluster".
  The diference is that cluster_ips will be calculated
  to be all range of machine local network
  according the network mask range (/16 or /24).
  """
  def init_auto_cluster(cluster_name,cluster_cookie,disc_copies \\ false,
                        table_names \\ [],connection_timeout \\ nil) do
    tables = table_names 
               |> prepare_tables()
    cluster_name
      |> DistributedMnesia.init_auto_cluster(
           cluster_cookie,
           disc_copies,
           tables,
           connection_timeout
         ) 
  end
  
  
  
  @doc """
  Provides cache functionality to  store SQL queries result. Return true or false.
  
  Keep the "amount_to_keep" most recent created/loaded entries from "table_name" table.
  All other entries will be removed/deleted. Return true or false.
  
  Requires mnesia already be started. 
  
  If you wish you application be able to scalabity then should be used
  ```elixir
  init_cluster(cluster_name,cluster_ips,ips_separator,disc_copies,table_names)
  ```
  function on application startup.
  """
  def put_cache(table_name,normalized_sql,params,resultset,amount_to_keep \\ 200) do
    result = table_name
               |> MnesiaUtil.put_cache([normalized_sql,params],resultset)
    cond do
      (result)
        -> table_name
             |> DistributedMnesia.set_updated_at([normalized_sql,params])
      true
        -> :ok
    end
    table_name
      |> DistributedMnesia.keep_only_last_used(amount_to_keep)         
    result
  end
  
  
  
  @doc """
  Provides cache functionality to load SQL queries result. Return the cache result or nil.
  
  Requires mnesia already be started. 
  
  If you wish you application be able to scalabity then should be used
  ```elixir
  init_cluster(cluster_name,cluster_ips,ips_separator,disc_copies,table_names)
  ```
  function on application startup.
  """
  def load_from_cache(table_name,normalized_sql,params) do
    table_name
      |> DistributedMnesia.load([normalized_sql,params])
      |> load_from_cache_result()
  end
  
  
  
  @doc """
  Provides cache functionality to clear SQL queries result. Return true or false.
  
  Requires mnesia already be started. 
  
  If you wish you application be able to scalabity then should be used
  ```elixir
  init_cluster(cluster_name,cluster_ips,ips_separator,disc_copies,table_names)
  ```
  function on application startup.
  """
  def clear_cache(table_name) do
    table_name
      |> DistributedMnesia.clear()
  end



  @doc """
  Add a new table in runtime execution to mnesia schema
  and replicate to other nodes. Return true or false.
  
  If table already was created in runtime, keep the actual table and return true.
  If table has same name from a table created in initialization, the operation will fail
  and will return false.
  You should keep control about the already created tables.
  
  "table_name" should be an atom.
  
  Requires mnesia already be started. 
  """
  @doc since: "1.1.26"
  def add_runtime_table(table_name) do           
    [table_name]
       |> prepare_tables()
       |> hd()
       |> DistributedMnesia.add_runtime_table()
  end
  
  
  
  #####################################
  #  Private functions
  #####################################
  defp prepare_tables(table_names,tables \\ []) do
    cond do
      (Enum.empty?(table_names))
        -> tables
      true
        -> table_names
             |> prepare_tables2(tables)
    end
  end


  
  defp prepare_tables2(table_names,tables) do
    table_names
      |> tl()
      |> prepare_tables(
           [
             %{
                table_name: table_names |> hd(), 
                table_attributes: [:id, :resultset] 
             }
             | tables
           ]
         )
  end

  
  
  defp load_from_cache_result(result) do
    cond do
      (nil == result)
        -> nil
      true
        -> result
             |> Tuple.to_list()
             |> Enum.at(2)
    end
  end


  
end


