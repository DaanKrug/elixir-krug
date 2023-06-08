defmodule Krug.ClusterUtil do

  @moduledoc """
  Utilitary module to handle cluster nodes operations
  """
  @moduledoc since: "1.1.17"
  
  
  
  @connection_node_timeout 100
  
  
  
  @doc """
  Connect the local node to a list of other nodes by their IP's "cluster_ips".
  Return a list (of atom) containing the sucessfully connected nodes. 
  """
  def connect_nodes(connected_nodes,cluster_name,cluster_ips) do
    cond do
      (Enum.empty?(cluster_ips))
        -> connected_nodes
      true 
        -> connected_nodes
             |> connect_nodes2(cluster_name,cluster_ips)
    end
  end
  
  
  
  ##########################################
  ### init functions
  ########################################## 
  defp connect_nodes2(connected_nodes,cluster_name,cluster_ips) do
    "#{cluster_name}@#{cluster_ips |> hd()}"
      |> String.to_atom()
      |> connect_nodes3(connected_nodes)
      |> connect_nodes(cluster_name,cluster_ips |> tl())
  end
  
  
  
  defp connect_nodes3(node,connected_nodes) do
    task = Task.async(
      fn ->
        :net_kernel.connect_node(node)
      end
    )
    %Task{pid: pid} = task
    :timer.sleep(@connection_node_timeout)
    cond do
      (Process.alive?(pid))
        -> connected_nodes
      (Task.await(task))
        -> [node | connected_nodes]
      true
        -> connected_nodes
    end
  end
  


end


