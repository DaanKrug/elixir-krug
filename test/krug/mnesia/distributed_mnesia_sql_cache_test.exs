defmodule Krug.DistributedMnesiaSqlCacheTest do
  use ExUnit.Case
  
  doctest Krug.DistributedMnesiaSqlCache
  
  alias Krug.DistributedMnesiaSqlCache
  
  test "[init_cluster|stop]" do
    cluster_cookie = "echo"
    cluster_name = "echo"
    cluster_ips = "192.168.1.12X "
    ips_separator = "X" 
    tables = [
      :users,
      :log,
      :other_table
    ]  
    
    created = cluster_name
                |> DistributedMnesiaSqlCache.init_cluster(cluster_cookie,cluster_ips,ips_separator,true,tables)
    
    assert created == true
    
    stopped = DistributedMnesiaSqlCache.shutdown()
    
    assert stopped == :ok
  end
  
end