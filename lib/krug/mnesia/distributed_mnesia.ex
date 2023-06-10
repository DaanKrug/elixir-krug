defmodule Krug.DistributedMnesia do
 
  @moduledoc """
  Utilitary module to handle Erlang Mnesia Database.
  Mnesia Database has single instance mode and also distributed mode
  that is purpose of this module. Single instance way don't allow us
  to improve horizontal scalability when we need.
  """
  @moduledoc since: "1.1.17"
  
  
  
  @metadata_table :distributed_mnesia_metadata_table
  
  
  
  alias Krug.MapUtil
  alias Krug.NetworkUtil
  alias Krug.MnesiaUtil
  alias Krug.ClusterUtil
  alias Krug.DateUtil
  
  
  
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
                   ips_separator \\ "|",disc_copies \\ false,tables \\ [],connection_timeout \\ nil) do
    local_node = cluster_name
                   |> NetworkUtil.start_local_node_to_cluster_ip_v4(cluster_cookie)
    cluster_ips = cluster_ips
                    |> NetworkUtil.extract_valid_ip_v4_addresses(ips_separator)
    connected_nodes = [local_node] 
                        |> ClusterUtil.connect_nodes(cluster_name,cluster_ips,connection_timeout)                 
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
  Almost the same that "init_cluster".
  The diference is that cluster_ips will be calculated
  to be all range of machine local network
  according the network mask range (/16 or /24).
  """
  def init_auto_cluster(cluster_name,cluster_cookie,disc_copies \\ false,tables \\ [], 
                        connection_timeout \\ nil) do
    cluster_name
      |> NetworkUtil.start_local_node_to_cluster_ip_v4(cluster_cookie)
    cluster_ips = NetworkUtil.get_local_wlan_ip_v4()
                    |> NetworkUtil.generate_ipv4_netmask_16_24_ip_list(
                         NetworkUtil.get_local_wlan_ip_v4_netmask()
                       )
    connected_nodes = [] 
                        |> ClusterUtil.connect_nodes(cluster_name,cluster_ips,connection_timeout)                 
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
    stored = table_name
               |> MnesiaUtil.store(id_row,data_row)
    cond do
      (stored)
        -> table_name
             |> set_updated_at(id_row)
      true
        -> :ok
    end 
    stored
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
    row_object = table_name
                   |> MnesiaUtil.load_from_cache(id_row)
    cond do
      (nil != row_object)
        -> table_name
             |> set_updated_at(id_row)
      true
        -> :ok
    end
    row_object
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
      |> remove_all_updated_at()
    table_name
      |> MnesiaUtil.clear_cache()
  end



  @doc """
  Get the last element in a table "table_name". Return the stored value or nil.
  
  Requires mnesia already be started. 
  """
  @doc since: "1.1.25"
  def load_last(table_name) do
    table_name
      |> MnesiaUtil.load_last()
  end
  
  
  
  @doc """
  Get the first element in a table "table_name". Return the stored value or nil.
  
  Requires mnesia already be started. 
  """
  @doc since: "1.1.25"
  def load_first(table_name) do
    table_name
      |> MnesiaUtil.load_first()
  end
  
  
  
  @doc """
  Executes a "select" operation against a "table_name" filtering by
  "array_params"
  
  Requires mnesia already be started. 
  """
  @doc since: "1.1.25"
  def select(table_name,array_params) do
    table_name
      |> MnesiaUtil.select(array_params)
  end
  
  
  
  @doc """
  Executes a "count" operation against a "table_name".
  
  Requires mnesia already be started. 
  """
  @doc since: "1.1.25"
  def count(table_name) do
    table_name
      |> MnesiaUtil.count()
  end
  
  
  
  @doc """
  Delete a row identified by "id_row" in a table 
  "table_name". Return true or false.
  
  Requires mnesia already be started. 
  """
  @doc since: "1.1.25"
  def delete(table_name,id_row) do
    total = table_name
              |> MnesiaUtil.count()
    table_name
      |> MnesiaUtil.delete(id_row)
    total_after_delete = table_name
                           |> MnesiaUtil.count()
    deleted = total_after_delete < total
    cond do
      (deleted)
        -> table_name
             |> remove_updated_at(id_row)
      true
        -> :ok
    end 
    deleted
  end
  
  
  
  @doc """
  Set last updated time of an entry on "table_name".
  Stores this data on metadata control table. Return true or false.
  
  Used by internal controls, and also exposes a way to other modules
  change this values (for example if you are caching something and needs
  to delete the oldest used objects - setting new value for updated_at each time
  that the object is used "loaded").
  """
  def set_updated_at(table_name,id_row) do
    id_row2 = "#{table_name}_#{id_row}"
    data_row = [
      table_name,
      id_row,
      DateUtil.get_date_time_now_millis()
    ]
    @metadata_table
      |> MnesiaUtil.store(id_row2,data_row)
  end
  
  
  
  @doc """
  Keep the "amount_to_keep" entries from "table_name" table.
  All other entries will be removed/deleted. Return true or false.
  
  Usefull for caching control (limit memory usage and others).
  With this you could limit each table to keep only the X last
  recent used (stored/loaded) entries, optimizing the memory
  usage and getting better caching performance - keeping in cache
  only the entries that are more often requested.
  
  Requires mnesia already be started. 
  """
  def keep_only_last_used(table_name,amount_to_keep) do
    table_name
      |> keep_only_last_used2(amount_to_keep)
  end
  
  
  
  #####################################
  #  Private functions
  #####################################
  defp start_mnesia(disc_copies,tables,connected_nodes) do
    System.cmd("epmd", ["-daemon"])
    :mnesia.start()
    :extra_db_nodes 
      |> :mnesia.change_config(connected_nodes)
    configured_tables = cond do
      (disc_copies)
        -> tables
             |> add_metadata_table()
             |> config_tables(:disc_copies)
      true
        -> tables
             |> add_metadata_table()
             |> config_tables(:ram_copies)
    end 
    cond do
      (!configured_tables)
        -> false
      true
        -> tables
             |> replicate_tables(connected_nodes)
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
    table_attributes = table 
                         |> MapUtil.get(:table_attributes)
    table_name
      |> :mnesia.create_table(
           [
             attributes: table_attributes,
             type: :set
           ]
         )
      |> config_tables5(mode,table_name,table_attributes |> hd())
  end
  
  
  
  defp config_tables5({:aborted, {:node_not_running, _}},_mode,_table_name,_table_index) do
    false
  end


  
  defp config_tables5({:aborted, {:already_exists,_}},mode,table_name,table_index) do
    table_name
      |> config_tables6(table_index,mode)
  end


  
  defp config_tables5({:atomic,:ok},mode,table_name,table_index) do
    table_name
      |> config_tables6(table_index,mode)
  end
  
  
  
  defp config_tables6(table_name,table_index,mode) do
    table_name
      |> :mnesia.add_table_index(table_index)
    table_name
      |> :mnesia.add_table_copy(node(),mode)
      |> config_tables7()
  end
  
  
  
  defp config_tables7({:atomic,:ok}) do
    true
  end
  
  
  
  defp config_tables7({:aborted,{:already_exists,_,_}}) do
    true
  end
  
  
  
  defp config_tables7({:aborted,_}) do
    false
  end


  
  defp replicate_tables(tables,connected_nodes) do
    table_names = tables
			        |> Enum.map(
			             fn(table) ->
			               table
			                 |> MapUtil.get(:table_name)
			             end
			           )
    table_names
      |> :mnesia.wait_for_tables(500)
    table_names
      |> Enum.map(
           fn(table_name) ->
             table_name
               |> replicate_table_on_nodes(connected_nodes)
           end
         )
    true
  end
  
  
  
  defp replicate_table_on_nodes(table_name,connected_nodes) do
    cond do
      (Enum.empty?(connected_nodes))
        -> :ok
      true
        -> table_name 
             |> replicate_table_on_nodes2(connected_nodes)
    end
  end
  
  
  
  defp replicate_table_on_nodes2(table_name,connected_nodes) do
    table_name
      |> :mnesia.add_table_copy(connected_nodes |> hd(),:ram_copies)
    table_name
      |> replicate_table_on_nodes(connected_nodes |> tl())
  end
  
  
  
  ########################################
  # Metadata functions
  ########################################
  defp add_metadata_table(tables) do
    [
      %{
         table_name: @metadata_table, 
         table_attributes: [:id,:object_table,:object_id,:updated_at] 
      }
      | tables  
    ]
  end
  

  
  defp remove_updated_at(table_name,id_row) do
    @metadata_table
      |> MnesiaUtil.delete("#{table_name}_#{id_row}")
  end



  defp remove_all_updated_at(table_name) do
    array_params = [
      {
        {@metadata_table,:"$1",:"$2",:"$3",:"$4"},
        [
          {:"==",:"$2",table_name}
        ],
        [:"$3"] 
      }
    ]
    id_rows = @metadata_table 
                |> select(array_params)
    table_name
      |> remove_all_updated_at2(id_rows)
  end



  defp remove_all_updated_at2(table_name,id_rows) do
    cond do
      (Enum.empty?(id_rows))
        -> :ok
      true
        -> table_name
             |> remove_all_updated_at3(id_rows)
    end
  end
  

  
  defp remove_all_updated_at3(table_name,id_rows) do
    table_name
      |> remove_updated_at(id_rows |> hd())
    table_name
      |> remove_all_updated_at2(id_rows |> tl())
  end
  


  defp keep_only_last_used2(table_name,amount_to_keep) do
    total = table_name
              |> count()
    cond do
      (nil == total)
        -> true
      (total <= amount_to_keep)
        -> true
      true
        -> table_name
             |> keep_only_last_used3(amount_to_keep,total)
    end     
  end
  
  
  
  defp keep_only_last_used3(table_name,amount_to_keep,total) do
    array_params = [
      {
        {@metadata_table,:"$1",:"$2",:"$3",:"$4"},
        [
          {:"==",:"$2",table_name}
        ],
        [:"$$"] 
      }
    ]
    all_rows = @metadata_table 
                 |> select(array_params)
    ordered_rows = :lists.sort(
                     fn(metadata_list_a,metadata_list_b) ->
                       (metadata_list_a |> Enum.at(3)) <= (metadata_list_b |> Enum.at(3))
                     end,
                     all_rows
                   )
    ordered_rows
      |> remove_old_rows(total - amount_to_keep,table_name)
  end
  
  
  
  defp remove_old_rows(ordered_rows,total_to_remove,table_name,counter \\ 0) do
    cond do
      (counter >= total_to_remove
        or Enum.empty?(ordered_rows))
          -> true
      true
        -> ordered_rows
             |> remove_old_rows2(total_to_remove,table_name,counter)
    end
  end



  defp remove_old_rows2(ordered_rows,total_to_remove,table_name,counter) do
    id_row = ordered_rows
               |> hd()
               |> Enum.at(2)
    table_name
      |> delete(id_row)          
    ordered_rows
      |> tl()
      |> remove_old_rows(total_to_remove,table_name,counter + 1) 
  end


  
end


