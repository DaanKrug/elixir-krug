defmodule Krug.DistributedMnesiaMasterControl do

  @moduledoc false

  @mnesia_task_control_table :mnesia_task_control_table
  @mnesia_master_node_task_key :mnesia_master_node_task_key
  @mnesia_full_range_ip_data_key :mnesia_full_range_ip_data_key 
  @metadata_table_key :metadata_table_key
  @startup_delay 10000
  @shutdown_timeout 1000
  @connection_timeout 100
  @verify_interval 100


  alias Krug.ClusterUtil  
  alias Krug.EtsUtil
  alias Krug.NetworkUtil
    
  
  def register_cluster_data(cluster_cookie,cluster_name,cluster_ips) do
    EtsUtil.new(@mnesia_task_control_table)
    EtsUtil.store_in_cache(
      @mnesia_task_control_table,
      @mnesia_full_range_ip_data_key,
      [
        cluster_cookie,
        cluster_name,
        cluster_ips
      ]
    )
  end
  
  def start_master_running_control(metadata_table) do
    EtsUtil.new(@mnesia_task_control_table)
    EtsUtil.store_in_cache(
      @mnesia_task_control_table,
      @metadata_table_key,
      metadata_table
    )
    @startup_delay 
             |> start_master_running_control2()
    Task.async(
      fn() 
        -> @startup_delay 
             |> start_master_running_control2()
      end
    )
    true
  end
  
  defp start_master_running_control2(timeout) do
    timeout
      |> :timer.sleep()
    task = Task.async(
             fn() 
               -> correct_master_node() 
             end
           )
    EtsUtil.store_in_cache(
      @mnesia_task_control_table,
      @mnesia_master_node_task_key,
      task
    )
    true
  end
  
  defp stop_master_running_control() do
    EtsUtil.read_from_cache(
      @mnesia_task_control_table,
      @mnesia_master_node_task_key
    )
      |> Task.shutdown(@shutdown_timeout)
  end
  
  defp correct_master_node() do
    cond do
      (node_is_running(node()))
        -> correct_master_node2()
      true
        -> stop_master_running_control()
    end
  end
  
  defp correct_master_node2() do
    master_nodes = read_master_nodes()
    cond do
      (nil == master_nodes
        or Enum.empty?(master_nodes))
          -> find_and_set_new_mnesia_master_node()
      (master_nodes |> hd() |> node_is_running())
        -> :ok
      true
        -> find_and_set_new_mnesia_master_node()
    end
    @verify_interval
      |> :timer.sleep()
  	correct_master_node()  
  end
  
  defp node_is_running(mnesia_node) do
    nil != mnesia_node |> read_master_nodes()
  end
  
  defp read_master_nodes(mnesia_node \\ node()) do
    metadata_table = EtsUtil.read_from_cache(
                       @mnesia_task_control_table,
                       @metadata_table_key
                     )
    case :rpc.call(mnesia_node,:mnesia,:table_info,[metadata_table,:master_nodes],@connection_timeout) do
      {:badrpc, _reason} 
        -> nil
      master_nodes 
        -> master_nodes
    end
  end
  
  defp find_and_set_new_mnesia_master_node() do
    ["find_and_set_new_mnesia_master_node"]
      |> IO.inspect()
    connected_nodes = reconnect_connected_nodes()
    :extra_db_nodes 
      |> :mnesia.change_config(connected_nodes)
    connected_nodes
      |> NetworkUtil.get_minor_node()
      |> set_master_node()
  end
  
  defp set_master_node(connected_node) do
    ["set_master_node"]
      |> IO.inspect()
    cond do
      (nil != connected_node)
        -> [connected_node] 
             |> :mnesia.set_master_nodes()
      true
        -> :ok
    end
  end
  
  defp reconnect_connected_nodes() do
    [
      _cluster_cookie,
      cluster_name,
      cluster_ips
    ] = EtsUtil.read_from_cache(
          @mnesia_task_control_table,
          @mnesia_full_range_ip_data_key
        )
    ClusterUtil.connect_nodes([],cluster_name,cluster_ips,@connection_timeout)
  end                 
      
end
