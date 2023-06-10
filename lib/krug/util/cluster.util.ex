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
  def connect_nodes(connected_nodes,cluster_name,cluster_ips,connection_timeout) do
    connection_timeout = cond do
      (nil == connection_timeout)
        -> @connection_node_timeout
      true
        -> connection_timeout
    end
    cluster_nodes = cluster_ips 
                      |> Enum.map(
                           fn(cluster_ip) ->
                             "#{cluster_name}@#{cluster_ip}"
                               |> String.to_atom()
                           end
                         )
                      |> Enum.chunk_every(25)
    connected_nodes
      |> connect_nodes2(cluster_nodes,connection_timeout)
  end
  
  
  
  ##########################################
  ### init functions
  ########################################## 
  def connect_nodes2(connected_nodes,cluster_nodes,connection_timeout) do
    cond do
      (Enum.empty?(cluster_nodes))
        -> connected_nodes
      true 
        -> connected_nodes
             |> connect_nodes3(cluster_nodes,connection_timeout)
    end
  end
  
  
  
  defp connect_nodes3(connected_nodes,cluster_nodes,connection_timeout) do
    cluster_nodes
      |> hd()
      |> connect_nodes4(connected_nodes,connection_timeout)
      |> connect_nodes2(
           cluster_nodes |> tl(),
           connection_timeout
         )
  end
  
  
  
  defp connect_nodes4(nodes,connected_nodes,connection_timeout) do
    task_nodes = nodes
                   |> enqueue_connection_tasks()
    connection_timeout
      |> :timer.sleep()
    connected_nodes
      |> verify_connected_nodes(task_nodes)
  end
  
  
  
  defp verify_connected_nodes(connected_nodes,task_nodes) do
    cond do
      (Enum.empty?(task_nodes))
        -> connected_nodes
      true
        -> connected_nodes
             |> verify_connected_nodes2(task_nodes)
    end
  end
  
  
  
  defp verify_connected_nodes2(connected_nodes,task_nodes) do
    [task,node] = task_nodes
                    |> hd()
    %Task{pid: pid} = task
    cond do
      (Process.alive?(pid))
        -> connected_nodes
             |> verify_connected_nodes(task_nodes |> tl())
      (Task.await(task))
        -> [node | connected_nodes]
             |> verify_connected_nodes(task_nodes |> tl())
      true
        -> connected_nodes
             |> verify_connected_nodes(task_nodes |> tl())
    end
  end



  defp enqueue_connection_tasks(nodes,tasks \\ []) do
    cond do 
      (Enum.empty?(nodes))
        -> tasks
      true
        -> nodes
             |> enqueue_connection_tasks2(tasks)
    end
  end


  
  defp enqueue_connection_tasks2(nodes,tasks) do
    node = nodes
             |> hd()
    task = Task.async(
      fn ->
        node
          |> :net_kernel.connect_node()
      end
    )
    nodes
      |> tl()
      |> enqueue_connection_tasks([[task,node] | tasks])
  end
  
  
  
end


