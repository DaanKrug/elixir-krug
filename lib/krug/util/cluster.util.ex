defmodule Krug.ClusterUtil do

  @moduledoc """
  Utilitary module to handle cluster nodes operations
  """
  @moduledoc since: "1.1.17"
  
  
  
  @connection_node_timeout 500
  
  
  
  @doc """
  Connect the local node to a list of other nodes by their IP's "cluster_ips".
  Return a list (of atom) containing the sucessfully connected nodes. 
  """
  def connect_nodes(connected_nodes,cluster_name,cluster_ips,connection_timeout) do
    connection_timeout = cond do
      (nil == connection_timeout)
        -> @connection_node_timeout
      true
        -> connection_timeout
    end
    cond do
      (Enum.empty?(cluster_ips))
        -> connected_nodes
      true 
        -> connected_nodes
             |> connect_nodes2(cluster_name,cluster_ips,connection_timeout)
    end
  end
  
  
  
  ##########################################
  ### init functions
  ########################################## 
  defp connect_nodes2(connected_nodes,cluster_name,cluster_ips,connection_timeout) do
    "#{cluster_name}@#{cluster_ips |> hd()}"
      |> String.to_atom()
      |> connect_nodes3(connected_nodes,connection_timeout)
      |> connect_nodes(
           cluster_name,
           cluster_ips |> tl(),
           connection_timeout
         )
  end
  
  
  
  defp connect_nodes3(node,connected_nodes,connection_timeout) do
    task = Task.async(
      fn ->
        :net_kernel.connect_node(node)
      end
    )
    %Task{pid: pid} = task
    connection_timeout
      |> :timer.sleep()
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


