defmodule Krug.BaseEctoDAOSqlCacheMnesia do

  @moduledoc """
  Utilitary module to handle resultset cache with mnesia, to improve
  performance and scalability. 
  
  Requires that Krug.DistributedMnesiaSqlCache already be previously started with
  "DistributedMnesiaSqlCache.init_cluster(...)"
  or 
  "DistributedMnesiaSqlCache.init_auto_cluster(...)"
  """
  @moduledoc since: "1.1.26"
  
  
  alias Krug.EtsUtil
  alias Krug.DistributedMnesiaSqlCache
  
  
  
  def load_from_cache(ets_key,table_name,normalized_sql,params) do
    exists = ets_key
               |> EtsUtil.read_from_cache("#{table_name}_runtime_table")
    cond do
      (nil == exists)
        -> nil
      true
        -> table_name
             |> String.to_atom()
             |> DistributedMnesiaSqlCache.load_from_cache(normalized_sql,params)
    end
  end
  
  
  
  def put_cache(ets_key,table_name,normalized_sql,params,resultset,cache_objects_per_table) do
    created = ets_key
               |> create_runtime_table(table_name)
    cond do
      (created)
        -> table_name
             |> String.to_atom()
             |> DistributedMnesiaSqlCache.put_cache(
                  normalized_sql,
                  params,
                  resultset,
                  cache_objects_per_table
                )
      true
        -> :ok
    end
	resultset
  end
  	 
  	 
  	  
  def clear_cache(_ets_key,table_name) do
    table_name
      |> String.to_atom()
      |> DistributedMnesiaSqlCache.clear_cache()
  end
  
  
  
  defp create_runtime_table(ets_key,table_name) do
    exists = ets_key
               |> EtsUtil.read_from_cache("#{table_name}_runtime_table")
    cond do
      (nil != exists)
        -> true
      true
        -> ets_key
            |> create_runtime_table2(table_name)
    end
  end


  
  defp create_runtime_table2(ets_key,table_name) do
    created = table_name
                |> String.to_atom()
                |> DistributedMnesiaSqlCache.add_runtime_table()
    cond do
      (!created)
        -> false
      true
        -> ets_key
             |> EtsUtil.store_in_cache("#{table_name}_runtime_table",:ok)
    end
  end


  	  
end


