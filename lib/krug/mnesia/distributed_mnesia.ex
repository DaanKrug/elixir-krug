defmodule Krug.DistributedMnesia do
 
  @moduledoc """
  Utilitary module to handle Erlang Mnesia Database.
  Mnesia Database has single instance mode and also distributed mode
  that is purpose of this module. Single instance way don't allow us
  to improve horizontal scalability when we need.
  """
  @moduledoc since: "1.1.17"
  
  
  
  alias Krug.MapUtil
  alias Krug.NetworkUtil
  alias Krug.MnesiaUtil
  alias Krug.ClusterUtil
  
  
  
  @doc """
  Start the distributed mnesia cluster. To be used on application start.
  
  ## Example
  
  ```elixir
  defmodule <Your_App_Main_Module_Name>.Application do
  
    @moduledoc false
  
    use Application
  
    alias Krug.DistributedMnesia


    def start(_type, _args) do
      Supervisor.start_link(children(), opts())
    end
  
    defp children() do
  	  [
  	    ...
  	    <Your_App_Main_Module_Name>.DistributedMnesiaTaskStarter, # calls Krug.DistributedMnesia.init_cluster(...)
  	    ...
  	  ]
    end
  
    defp opts() do 
  	  [strategy: :one_for_one, name: <Your_App_Main_Module_Name>.Supervisor]
    end 
    
  end
  ```
  
  ```elixir
  defmodule <Your_App_Main_Module_Name>.DistributedMnesiaConfigTaskStarter do
    def child_spec(opts) do
      %{id: __MODULE__,start: {__MODULE__, :start_link, [opts]}}
    end
  
    def start_link(opts) do
      Supervisor.start_link([{<Your_App_Main_Module_Name>.DistributedMnesiaConfigTask,opts}], strategy: :one_for_one)
    end
  end
  ```
  
  ```elixir
  defmodule <Your_App_Main_Module_Name>.DistributedMnesiaConfigTask do
 
    use Task
    alias Krug.DistributedMnesia
 
    def start_link(opts) do
      Task.start_link(__MODULE__, :run, [opts])
    end

    def run(_opts) do
      cluster_cookie = "echo"
      cluster_name = "echo"
      cluster_ips = "192.168.1.12X "
      ips_separator = "X" 
      tables = [
        %{
           table_name: :users, 
           table_attributes: [:id, :name, :email, :last_access] 
        },
        %{
           table_name: log, 
           table_attributes: [:id, :user_id, :action, :date_time] 
        },
      ]  
    
      cluster_name
        |> DistributedMnesia.init_cluster(cluster_cookie,cluster_ips,ips_separator,true,tables)
    end
  
  end
  ```
  
  disc_copies: true for ":disc_copies" (ram + disc), false for ":ram_copies" (only ram).
  
  tables: list of map table configurations
  ```elixir
  %{
    table_name: :users, # atom
    table_attributes: [:id, :name, :email] # atom list | the first element is the "id_row" value/column
  }
  ```
  .
  
  connected_nodes: list (of atom) nodes already connected in a erlang cluster.
  """
  def init_cluster(cluster_name,cluster_cookie,cluster_ips,
                   ips_separator \\ "|",disc_copies \\ false,tables \\ []) do
    local_node = cluster_name
                   |> NetworkUtil.start_local_node_to_cluster_ip_v4(cluster_cookie)
    cluster_ips = cluster_ips
                    |> NetworkUtil.extract_valid_ip_v4_addresses(ips_separator)
    connected_nodes = [local_node] 
                        |> ClusterUtil.connect_nodes(cluster_name,cluster_ips)                 
    cond do
      (Enum.empty?(connected_nodes))
        -> false
      true
        -> disc_copies
             |> start_mnesia(
                  tables,
                  connected_nodes
                )
    end
  end
  
  
  
  @doc """
  Stores an object "data_row" identified by "id_row" on "table_name". 
  Return true or false.
  
  Requires mnesia already be started. 
  
  If you wish you application be able to scalabity then should be used
  ```elixir
  init_cluster(cluster_name,cluster_ips,ips_separator,disc_copies,tables)
  ```
  function on application startup.
  """
  def store(table_name,id_row,data_row) do
    table_name
      |> MnesiaUtil.put_cache(id_row,data_row)
  end
  
  
  
  @doc """
  Retrieves an object identified by "id_row" from "table_name". 
  Return the registry entry or nil.
  
  Requires mnesia already be started. 
  
  If you wish you application be able to scalabity then should be used
  ```elixir
  init_cluster(cluster_name,cluster_ips,ips_separator,disc_copies,tables)
  ```
  function on application startup.
  """
  def load(table_name,id_row) do
    table_name
      |> MnesiaUtil.load_from_cache(id_row)
  end
  
  
  
  @doc """
  Removes all object entries from "table_name". Return true or false.
  
  Requires mnesia already be started. 
  
  If you wish you application be able to scalabity then should be used
  ```elixir
  init_cluster(cluster_name,cluster_ips,ips_separator,disc_copies,tables)
  ```
  function on application startup.
  """
  def clear(table_name) do
    table_name
      |> MnesiaUtil.clear_cache()
  end



  #####################################
  #  Private functions
  #####################################
  defp start_mnesia(disc_copies,tables,connected_nodes) do
    :mnesia.stop()
    System.cmd("epmd", ["-daemon"])
    [node()]
      |> :mnesia.create_schema()
    :mnesia.start()
    :extra_db_nodes 
      |> :mnesia.change_config(connected_nodes)
    cond do
      (disc_copies)
        -> tables
             |> config_tables(:disc_copies)
      true
        -> tables
             |> config_tables(:ram_copies)
    end 
  end
  
  
  
  defp config_tables(tables,mode) do
    :schema
      |> :mnesia.change_table_copy_type(node(),mode)
    tables
      |> config_tables2(mode)
  end


  
  defp config_tables2(tables,mode) do
    cond do
      (Enum.empty?(tables))
        -> true
      true
        -> tables
             |> config_tables3(mode)
    end
  end


  
  defp config_tables3(tables,mode) do
    cond do
      (config_tables4(tables,mode))
        -> tables
             |> tl()
             |> config_tables2(mode)
      true
        -> false 
    end
  end
  
  
  
  defp config_tables4(tables,mode) do
    table = tables
              |> hd()
    table_name = table 
                   |> MapUtil.get(:table_name)
    table_attibutes = table 
                        |> MapUtil.get(:table_attibutes)
    table_name
      |> :mnesia.create_table(attributes: table_attibutes)
      |> config_tables5(mode,table_name)
  end
  
  
  
  defp config_tables5({:aborted, {:node_not_running, _}},_mode,_table_name) do
    false
  end


  
  defp config_tables5({:aborted, {:already_exists,_}},_mode,_table_name) do
    true
  end


  
  defp config_tables5({:atomic,:ok},mode,table_name) do
    table_name
      |> :mnesia.add_table_copy(node(),mode)
      |> config_tables6()
  end
  
  
  
  defp config_tables6({:atomic,:ok}) do
    true
  end
  
  
  
  defp config_tables6({:aborted,{:already_exists,_,_}}) do
    true
  end
  
  
  
  defp config_tables6({:aborted,_}) do
    false
  end


  
end


