defmodule Krug.DistributedMnesiaSqlCache do
 
  @moduledoc """
  Utilitary module to handle Erlang Mnesia Database.
  Mnesia Database has single instance mode and also distributed mode
  that is purpose of this module. Single instance way don't allow us
  to improve horizontal scalability when we need.
  """
  @moduledoc since: "1.1.17"
  
  
  require Logger
  alias Krug.StringUtil
  alias Krug.MapUtil
  
  @ip_regexp ~r/^\d+\.\d+\.\d+\.\d+$/
  
  
    
  
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
    local_node = "#{cluster_name}@#{get_local_wlan_ip()}" 
                   |> String.to_atom()
    [
      local_node,
      :longnames
    ]
      |> :net_kernel.start()
    cluster_cookie
      |> String.to_atom()
      |> :erlang.set_cookie() 
    cluster_ips = cluster_ips
                    |> StringUtil.trim()
                    |> StringUtil.split(ips_separator)
                    |> Enum.filter(
                         fn 
                           ip -> String.match?(ip,@ip_regexp) 
                         end
                       )
    connected_nodes = [local_node] 
                        |> connect_nodes(cluster_name,cluster_ips)
    cond do
      (Enum.empty?(connected_nodes))
        -> false
      true
        -> disc_copies
             |> start_mnesia(tables,connected_nodes)
    end
  end
  
  
  
  @doc """
  Shutdown the local node of mnesia.
  
  Requires mnesia already be started.
  """
  def shutdown() do
    :mnesia.stop()
    :mnesia.delete_schema([node()])
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
    write_data = fn ->
      id = {normalized_sql,params}
      :mnesia.write({table_name,id,resultset})
    end
    write_data
      |> :mnesia.transaction()
      |> put_cache_result()
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
    id = {normalized_sql,params}
    read_data = fn ->
      :mnesia.read({table_name,id})
    end
    read_data
      |> :mnesia.transaction()
      |> load_from_cache_result(table_name,id)
  end
  
  
  
  @doc """
  Provides cache functionality to clear SQL queries result. Return the cache result or nil.
  
  Requires mnesia already be started. 
  
  If you wish you application be able to scalabity then should be used
  ```elixir
  init_cluster(cluster_name,cluster_ips,ips_separator,disc_copies,tables)
  ```
  function on application startup.
  """
  def clear_cache(table_name) do
	table_name
	  |> :mnesia.all_keys()
	  |> remove_all_table_cached_results(table_name)
  end
  
  
  
  ##########################################
  # Private functions
  ##########################################
  
  ##########################################
  ### init functions
  ########################################## 
  defp connect_nodes(connected_nodes,cluster_name,cluster_ips) do
    cond do
      (Enum.empty?(cluster_ips))
        -> connected_nodes
      true 
        -> connected_nodes
             |> connect_nodes2(cluster_name,cluster_ips)
    end
  end
  
  
  
  defp connect_nodes2(connected_nodes,cluster_name,cluster_ips) do
    "#{cluster_name}@#{cluster_ips |> hd()}"
      |> String.to_atom()
      |> connect_nodes3(connected_nodes)
      |> connect_nodes(cluster_name,cluster_ips |> tl())
  end
  
  
  
  defp connect_nodes3(node,connected_nodes) do
    cond do
      (:net_kernel.connect_node(node))
        -> [node | connected_nodes]
      true
        -> connected_nodes
    end
  end
  
  
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
    table
      |> :mnesia.create_table(attributes: [:id, :resultset])
      |> config_tables5(mode,table)
  end
  
  
  
  defp config_tables5({:aborted, {:node_not_running, _}},_mode,_table) do
    false
  end


  
  defp config_tables5({:aborted, {:already_exists,_}},_mode,_table) do
    true
  end


  
  defp config_tables5({:atomic,:ok},mode,table) do
    table
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


  
  ##########################################
  ### store functions
  ########################################## 
  defp put_cache_result({:atomic, :ok}) do
    true  
  end
  
  
  
  defp put_cache_result(_) do
    false  
  end



  ########################################## 
  ### load functions
  ########################################## 
  defp load_from_cache_result({:atomic,key_entry_array},table_name,id) do
    cond do
      (Enum.empty?(key_entry_array))
        -> nil
      true
        -> key_entry_array
             |> hd()
             |> load_from_cache_result2(table_name,id)
    end
  end
  
  
  
  defp load_from_cache_result(_,_table_name,_id) do
    nil
  end
  
  
  
  defp load_from_cache_result2(key_entry,table_name,id) do
    {table_name_entry,id_entry,resultset} = key_entry
    cond do
      (nil == resultset
        or table_name_entry != table_name
          or id_entry != id)
            -> nil
      true
        -> resultset
    end
  end
  

  
  ########################################## 
  ### clear cache functions
  ########################################## 
  defp remove_all_table_cached_results(keys,table_name) do
    cond do
      (Enum.empty?(keys))
        -> :ok
      true
        -> keys
             |> remove_all_table_cached_results2(table_name)
    end
  end

  
  
  defp remove_all_table_cached_results2(keys,table_name) do
    table_name
      |> :mnesia.delete(keys |> hd(),:write)
    keys
      |> tl()
      |> remove_all_table_cached_results(table_name)
  end



  ########################################## 
  ### IP functions
  ########################################## 
  defp get_local_wlan_ip() do
    :inet.getifaddrs()
      |> Tuple.to_list()
      |> tl()
      |> hd()
      |> filter_local_wlan_ip()
  end
  
  
  
  defp filter_local_wlan_ip(ips_list, local_ip \\ nil) do
    cond do
      (Enum.empty?(ips_list))
        -> local_ip
      true
        -> ips_list
             |> filter_local_wlan_ip2()
    end
  end


  
  defp filter_local_wlan_ip2(ips_list) do
    list = ips_list 
             |> hd()
             |> Tuple.to_list()
    cond do
      (String.starts_with?("#{list |> hd()}","wl"))
        -> filter_local_wlan_ip([], list |> extract_local_ip())
      true
        -> ips_list 
             |> tl() 
             |> filter_local_wlan_ip()
    end
  end
  

  
  defp extract_local_ip(list) do
    data = list
             |> tl() 
             |> hd()
             |> Enum.filter(
                  fn({k,v}) ->
                    (k == :addr and :inet.is_ipv4_address(v))
                  end
                )
    data 
      |> Enum.into(%{})
      |> MapUtil.get(:addr)
      |> :inet.ntoa()
  end


  
end


