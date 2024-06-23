defmodule Krug.DistributedMnesiaMasterControl do

  @moduledoc false

  @mnesia_task_control_table :mnesia_task_control_table
  @mnesia_cluster_data_key :mnesia_cluster_data_key 
  @metadata_table_key :metadata_table_key
  @connection_timeout 100
  @correct_master_node_interval_key :correct_master_node_interval_key

 
 
  alias Krug.EtsUtil
  alias Krug.ClusterUtil
  alias Krug.NetworkUtil
    

  
  def read_metadata_table() do
    EtsUtil.read_from_cache(
      @mnesia_task_control_table,
      @metadata_table_key
    )
  end


  
  def read_cluster_data() do
    EtsUtil.read_from_cache(
      @mnesia_task_control_table,
      @mnesia_cluster_data_key
    )
  end
  
  
  
  def read_correct_master_node_interval() do
    EtsUtil.read_from_cache(
      @mnesia_task_control_table,
      @correct_master_node_interval_key
    )
  end


  
  def register_cluster_data(cluster_cookie,cluster_name,cluster_ips) do
    EtsUtil.new(@mnesia_task_control_table)
    EtsUtil.store_in_cache(
      @mnesia_task_control_table,
      @mnesia_cluster_data_key,
      [
        cluster_cookie,
        cluster_name,
        cluster_ips
      ]
    )
  end


  
  def start_master_running_control(metadata_table,correct_master_node_interval) do
    EtsUtil.new(@mnesia_task_control_table)
    EtsUtil.store_in_cache(
      @mnesia_task_control_table,
      @metadata_table_key,
      metadata_table
    )
    EtsUtil.store_in_cache(
      @mnesia_task_control_table,
      @correct_master_node_interval_key,
      correct_master_node_interval
    )
    Supervisor.start_link([{Krug.DistributedMnesiaMasterControlTask,[]}], strategy: :one_for_one)
    true
  end



  def verify_and_correct_master_node() do
    master_nodes = read_master_nodes()
    # ["master_nodes => ", master_nodes] |> IO.inspect()
    cond do
      (nil == master_nodes
        or Enum.empty?(master_nodes))
          -> find_and_set_new_mnesia_master_node()
      (!(master_nodes |> hd() |> node_is_running()))
        -> find_and_set_new_mnesia_master_node()
      true
        -> master_nodes 
             |> hd() 
             |> find_and_set_new_mnesia_master_node()
    end
  end
  
  
  
  def node_is_running(mnesia_node) do
    nil != mnesia_node |> read_master_nodes()
  end



  defp read_master_nodes(mnesia_node \\ node()) do
    params = [
      read_metadata_table(),
      :master_nodes
    ]
    case :rpc.call(mnesia_node,:mnesia,:table_info,params,@connection_timeout) do
      {:badrpc, _reason} 
        -> nil
      master_nodes 
        -> master_nodes
    end
  end


  
  defp find_and_set_new_mnesia_master_node(actual_master_node \\ nil) do
    # ["find_and_set_new_mnesia_master_node"] |> IO.inspect()
    connected_nodes = reconnect_connected_nodes()
    :extra_db_nodes 
      |> :mnesia.change_config(connected_nodes)
    connected_nodes
      |> NetworkUtil.get_minor_node()
      |> set_master_node(actual_master_node)
  end


  
  defp set_master_node(node_to_be_new_master,actual_master_node) do
    # ["set_master_node",node_to_be_new_master] |> IO.inspect()
    cond do
      (node_to_be_new_master == actual_master_node)
        -> :ok
      (nil != node_to_be_new_master)
        -> [node_to_be_new_master] 
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
    ] = read_cluster_data()
    ClusterUtil.connect_nodes([],cluster_name,cluster_ips,@connection_timeout)
  end  


                     
end


