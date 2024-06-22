defmodule Krug.DistributedMnesiaSync do

  @moduledoc false
  
  require Logger
  alias Krug.MapUtil
  alias Krug.DistributedMnesiaCreator
  alias Krug.DistributedMnesiaCloner
  
  
  def sync_tables(cluster_node,tables,storage_mode,connection_timeout) do                    
    sync_tables(
      tables,
      storage_mode,
      cluster_node,
      get_table_cookies(node(),connection_timeout),
      cluster_node
        |> get_table_cookies(connection_timeout)
    )
  end
  
  defp sync_tables(tables,storage_mode,_cluster_node,{:ok, local_cookies},{:ok, remote_cookies}) do
    Enum.each(
      tables, 
      fn(table) 
        -> table
             |> sync_table(storage_mode,local_cookies,remote_cookies)
      end
    )    
  end
  
  defp sync_tables(_tables,_storage_mode,cluster_node,{:error, reason},{:ok, _remote_cookies}) do
    Logger.info(
      """
      [Krug.DistributedMnesiaSync] => 
      Error getting mnesia tables cookies for local node #{inspect(cluster_node)}, reason: #{inspect(reason)}
      """
    )
  end
  
  defp sync_tables(_tables,_storage_mode,cluster_node,{:ok, _local_cookies},{:error, reason}) do
    Logger.info(
      """
      [Krug.DistributedMnesiaSync] => 
      Error getting mnesia tables cookies for remote node #{inspect(cluster_node)}, reason: #{inspect(reason)}
      """
    )
  end
  
  defp sync_tables(_tables,_storage_mode,cluster_node,{:error, local_reason},{:error, remote_reason}) do
    Logger.info(
      """
      [Krug.DistributedMnesiaSync] => Multiple errors:
      Error getting mnesia tables cookies for local node #{inspect(node())}, reason: #{inspect(local_reason)}
      Error getting mnesia tables cookies for remote node #{inspect(cluster_node)}, reason: #{inspect(remote_reason)}
      """
    )
  end
  
  defp sync_table(table,storage_mode,local_cookies,remote_cookies) do
    tablename = table
                  |> MapUtil.get(:table_name)
    table
      |> sync_table(
           storage_mode,
           {local_cookies[tablename],remote_cookies[tablename]}
         )
  end
  
  defp sync_table(table,storage_mode,{nil,nil}) do
    table
      |> DistributedMnesiaCreator.create_table(storage_mode)
  end
  
  defp sync_table(table,storage_mode,{nil,_}) do
    table
      |> DistributedMnesiaCloner.add_table_copy(storage_mode)
  end
  
  defp sync_table(table,_storage_mode,{_,nil}) do
    Logger.info(
      """
      [Krug.DistributedMnesiaSync] => 
      [#{inspect(node())}] #{inspect(table)}: no remote data to copy found.
      """
    )
  end
  
  defp sync_table(_table,_storage_mode,{_local,_remote}) do
    #Logger.info(
    #  """
    #  [Krug.DistributedMnesiaSync] => 
    #  [#{inspect(node())}] #{inspect(table)}: table found on both sides, copy aborted.
    #  """
    #)
  end
  
  defp get_table_cookies(node,connection_timeout) do
    case :rpc.call(node, :mnesia, :system_info, [:local_tables],connection_timeout) do
      {:badrpc, reason} 
        -> {:error, reason}
      tables 
        -> node
             |> get_table_cookies(tables,connection_timeout)
    end
  end

  defp get_table_cookies(node,tables,connection_timeout) do
    Enum.reduce_while(
      tables, 
      {:ok, %{}}, 
      fn(table,{:ok, acc}) 
        -> node_table_cookie(node,table,connection_timeout,{:ok, acc})
      end
    )
  end
  
  defp node_table_cookie(node,table,connection_timeout,{:ok, acc}) do
    case :rpc.call(node,:mnesia,:table_info,[table, :cookie],connection_timeout) do
      {:badrpc, reason} 
        -> {:halt, {:error, reason}}
      cookie 
        -> {:cont, {:ok, Map.put(acc, table, cookie)}}
    end
  end

end
