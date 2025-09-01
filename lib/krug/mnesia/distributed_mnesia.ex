defmodule Krug.DistributedMnesia do
 
  @moduledoc """
  Utilitary module to handle Erlang Mnesia Database.
  Mnesia Database has single instance mode and also distributed mode
  that is purpose of this module. Single instance way don't allow us
  to improve horizontal scalability when we need.
  """
  @moduledoc since: "1.1.17"

  
  
  require Logger  
  
  @metadata_table :distributed_mnesia_metadata_table
  @nodes_metadata_table :distributed_mnesia_nodes_metadata_table
  @runtime_tables "distributed_mnesia_runtime_tables"
  
  
  
  alias Krug.MapUtil
  alias Krug.NetworkUtil
  alias Krug.MnesiaUtil
  alias Krug.ClusterUtil
  alias Krug.DateUtil
  alias Krug.DistributedMnesiaSync
  alias Krug.DistributedMnesiaCreator
  alias Krug.DistributedMnesiaMasterControl
  
  
  
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
  
  connection_timeout: connection timeout (milliseconds) for connect to other nodes.
  
  cloud_provider: "localhost", AWS, GCP, Azure - or empty to use node@1.1.1.1 host format (localhost or normal network)
  only AWS supported for now.
  
  correct_master_node_interval: interval (milliseconds) to verification task make auto adjust the master node.
  By default is 2 seconds to preserve machine resources
  """
  def init_cluster(cluster_name,cluster_cookie,cluster_ips,
                   ips_separator \\ "|",disc_copies \\ false,tables \\ [],
                   connection_timeout \\ 100, 
                   correct_master_node_interval \\ 2000,
                   cloud_provider \\ "") do
    System.cmd("epmd", ["-daemon"])
    :mnesia.start()
    local_node = cluster_name
                   |> NetworkUtil.start_local_node_to_cluster_ip_v4(cluster_cookie,cloud_provider)
    cluster_ips = cluster_ips
                    |> NetworkUtil.extract_valid_ip_v4_addresses(ips_separator)
    cluster_cookie 
      |> DistributedMnesiaMasterControl.register_cluster_data(
           cluster_name,
           cluster_ips
         )
    connected_nodes = [local_node] 
                        |> ClusterUtil.connect_nodes(cluster_name,cluster_ips,connection_timeout)
    cond do
      (Enum.empty?(connected_nodes))
        -> false
      true
        -> disc_copies
             |> start_mnesia(
                  tables,
                  connected_nodes,
                  connection_timeout,
                  correct_master_node_interval
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
                        connection_timeout \\ 100, 
                        correct_master_node_interval \\ 2000,
                        cloud_provider \\ "") do
    System.cmd("epmd", ["-daemon"])
    cluster_name
      |> NetworkUtil.start_local_node_to_cluster_ip_v4(cluster_cookie,cloud_provider)
    cluster_ips = NetworkUtil.get_local_wlan_ip_v4()
                    |> NetworkUtil.generate_ipv4_netmask_16_24_ip_list(
		                 NetworkUtil.get_local_wlan_ip_v4_netmask()
		               )
    cluster_cookie 
      |> DistributedMnesiaMasterControl.register_cluster_data(
           cluster_name,
           cluster_ips
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
                  connected_nodes,
                  connection_timeout,
                  correct_master_node_interval
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
    deleted = table_name
                |> MnesiaUtil.delete(id_row)
    deleted = deleted == {:atomic,:ok}
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
  
  
  
  @doc """
  Add a new table in runtime execution to mnesia schema
  and replicate to other nodes. Return true or false.
  
  If table already was created in runtime, keep the actual table and return true.
  If table has same name from a table created in initialization, the operation will fail
  and will return false.
  You should keep control about the already created tables.
  
  Should be in a same format as when define tables for initialization:
  ```elixir
  %{
    table_name: :my_table_name, 
    table_attributes: [:attr_1, :attr_2, ...  :attr_N] 
  }
  ```
  
  Requires mnesia already be started. 
  """
  @doc since: "1.1.26"
  def add_runtime_table(table) do
    cond do
      (!MnesiaUtil.mnesia_started())
        -> false
      true
        -> table
             |> add_runtime_table2()
    end
  end
  
  
  
  #####################################
  #  Private functions
  #####################################
  defp start_mnesia(disc_copies,tables,connected_nodes,connection_timeout,correct_master_node_interval) do
   @nodes_metadata_table
      |> MnesiaUtil.delete(@runtime_tables)
    @nodes_metadata_table
      |> MnesiaUtil.put_cache(@runtime_tables,[])
    storage_mode = cond do
      (disc_copies)
        -> :disc_copies
      true
        -> :ram_copies
    end
    :mnesia.start()
    local = node()
    not_local_nodes = connected_nodes
	                    |> Enum.uniq()
	                    |> Enum.reject(&(&1 == local))
	cond do
	  (not_local_nodes |> Enum.empty?())
	    -> :ok
	  true
	    -> not_local_nodes
	         |> then(& :mnesia.change_config(:extra_db_nodes, &1))
	end
    tables = tables
               |> add_metadata_table()
               |> add_nodes_metadata_table()
    :schema
      |> :mnesia.change_table_copy_type(node(),storage_mode)
    configured_tables = connected_nodes
                          |> sync_tables(tables,storage_mode,connection_timeout)
    cond do
      (!configured_tables)
        -> false
      (!(tables |> verify_tables_ok()))
        -> re_start_mnesia(disc_copies,tables,connected_nodes,connection_timeout,correct_master_node_interval)
      true
        -> @metadata_table
             |> DistributedMnesiaMasterControl.start_master_running_control(
                  correct_master_node_interval
                )
    end
  end
  
  
  
  defp re_start_mnesia(disc_copies,tables,connected_nodes,connection_timeout,correct_master_node_interval) do
    Logger.info("start mnesia failed ... correct master node and wait for 1 second")
    DistributedMnesiaMasterControl.verify_and_correct_master_node()
    :timer.sleep(1000)
    :mnesia.stop()
    disc_copies
      |> start_mnesia(tables,connected_nodes,connection_timeout,correct_master_node_interval)
  end
  
  
  
  defp verify_tables_ok(tables) do
    cond do
      (Enum.empty?(tables))
        -> true
      (!(tables |> hd() |> verify_table_config_ok()))
        -> false
      true
        -> tables
             |> tl()
             |> verify_tables_ok()
    end
  end
  
  
  
  defp verify_table_config_ok(table) do
    table_name = table
                   |> MapUtil.get(:table_name)
    result = table_name
               |> MnesiaUtil.load_from_cache(1,true)
    result != {:aborted,{:no_exists,table_name}}
  end
  
  
  
  defp sync_tables(nodes,tables,storage_mode,connection_timeout) do
    cond do
      (Enum.empty?(nodes))
        -> true
      true
        -> nodes
             |> sync_tables2(tables,storage_mode,connection_timeout)
    end
  end
  
  
  
  defp sync_tables2(nodes,tables,storage_mode,connection_timeout) do
    nodes 
      |> hd()
      |> DistributedMnesiaSync.sync_tables(tables,storage_mode,connection_timeout)
    nodes
      |> tl()
      |> sync_tables(tables,storage_mode,connection_timeout)
  end
  

  
  ########################################
  # Node metadata functions
  ########################################
  def add_runtime_table2(table) do
    cond do
      (table |> runtime_table_already_exists())
        -> true
      true
        -> table
             |> add_runtime_table3()
    end
  end
  
  
  
  defp add_nodes_metadata_table(tables) do
    [
      %{
         table_name: @nodes_metadata_table, 
         table_attributes: [:id,:content] 
      }
      | tables  
    ]
  end
  
  
  
  defp runtime_table_already_exists(table) do
    tables_array = @runtime_tables
                     |> load_nodes_metadata()
    cond do
      (nil == tables_array
        or Enum.empty?(tables_array)
          or Enum.empty?(tables_array |> hd()))
            -> false
      true
        -> tables_array
             |> hd() 
             |> runtime_table_already_exists2(table)
    end
  end
  
  
  
  defp runtime_table_already_exists2(tables_array,table) do
    cond do
      (Enum.empty?(tables_array))
        -> false
      true
        -> tables_array
             |> runtime_table_already_exists3(table)
    end
  end
  
  
  
  defp runtime_table_already_exists3(tables_array,table) do
    cond do
      (table |> MapUtil.get(:table_name) 
        == tables_array |> hd() |> MapUtil.get(:table_name))
          -> true
      true
        -> tables_array
             |> tl()
             |> runtime_table_already_exists2(table)
    end
  end
  
  
  
  defp add_runtime_table3(table) do
    table
      |> DistributedMnesiaCreator.create_table(:ram_copies)
    table
      |> store_new_runtime_table_added()
  end
  
  
  
  defp store_new_runtime_table_added(table) do
    tables_array = @runtime_tables
                     |> load_nodes_metadata()
    cond do
      (nil == tables_array 
        or Enum.empty?(tables_array))
          -> @nodes_metadata_table
               |> MnesiaUtil.put_cache(@runtime_tables,[table])
      true
        -> @nodes_metadata_table
             |> MnesiaUtil.put_cache(@runtime_tables,[table | tables_array |> hd()])
    end          
    true
  end
  
  
  
  defp load_nodes_metadata(attr_key) do
    array_params = [
      {
        {@nodes_metadata_table,:"$1",:"$2"},
        [
          {:"==",:"$1",attr_key}
        ],
        [:"$2"] 
      }
    ]
    @nodes_metadata_table 
      |> select(array_params)
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
    cond do
      (nil == all_rows
        or Enum.empty?(all_rows))
          -> :ok
      (all_rows |> length() <= amount_to_keep)
        -> :ok
      true
        -> table_name
             |> keep_only_last_used3(amount_to_keep,all_rows)
    end         
  end
  
  
  
  defp keep_only_last_used3(table_name,amount_to_keep,all_rows) do
    total = all_rows 
              |> length()
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


