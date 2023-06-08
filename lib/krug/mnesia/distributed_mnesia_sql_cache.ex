defmodule Krug.DistributedMnesiaSqlCache do
 
  @moduledoc """
  Utilitary module to handle Erlang Mnesia Database.
  Mnesia Database has single instance mode and also distributed mode
  that is purpose of this module. Single instance way don't allow us
  to improve horizontal scalability when we need.
  """
  @moduledoc since: "1.1.17"
  
  
  
  #require Logger
  alias Krug.NetworkUtil
  alias Krug.MnesiaUtil
  alias Krug.ClusterUtil
  alias Krug.DistributedMnesia
  
  
  
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
      tables = [
        :users,
        :log,
        :other_table
      ]  
    
      cluster_name
        |> DistributedMnesiaSqlCache.init_cluster(cluster_cookie,cluster_ips,ips_separator,true,tables)
    end
  
  end
  ```
  """
  def init_cluster(cluster_name,cluster_cookie,cluster_ips,
                   ips_separator \\ "|",disc_copies \\ false,tables \\ []) do
    local_node = cluster_name
                   |> NetworkUtil.start_local_node_to_cluster_ip_v4(cluster_cookie)
    cluster_ips = cluster_ips
                    |> NetworkUtil.extract_valid_ip_addresses(ips_separator)
    connected_nodes = [local_node] 
                        |> ClusterUtil.connect_nodes(cluster_name,cluster_ips)
                        
                        
                        
    #  [:id, :resultset]                  
    cond do
      (Enum.empty?(connected_nodes))
        -> false
      true
        -> disc_copies
             |> DistributedMnesia.start_mnesia(tables,connected_nodes)
    end
  end
  
  
  
  @doc """
  Provides cache functionality to  store SQL queries result. Return true or false.
  
  Requires mnesia already be started. 
  
  If you wish you application be able to scalabity then should be used
  ```elixir
  init_cluster(cluster_name,cluster_ips,ips_separator,disc_copies,tables)
  ```
  function on application startup.
  """
  def put_cache(table_name,normalized_sql,params,resultset) do
    table_name
      |> MnesiaUtil.put_cache({normalized_sql,params},resultset)
  end
  
  
  
  @doc """
  Provides cache functionality to load SQL queries result. Return the cache result or nil.
  
  Requires mnesia already be started. 
  
  If you wish you application be able to scalabity then should be used
  ```elixir
  init_cluster(cluster_name,cluster_ips,ips_separator,disc_copies,tables)
  ```
  function on application startup.
  """
  def load_from_cache(table_name,normalized_sql,params) do
    table_name
      |> MnesiaUtil.load_from_cache({normalized_sql,params})
  end
  
  
  
  @doc """
  Provides cache functionality to clear SQL queries result. Return true or false.
  
  Requires mnesia already be started. 
  
  If you wish you application be able to scalabity then should be used
  ```elixir
  init_cluster(cluster_name,cluster_ips,ips_separator,disc_copies,tables)
  ```
  function on application startup.
  """
  def clear_cache(table_name) do
    table_name
      |> MnesiaUtil.clear_cache()
  end

  
end


