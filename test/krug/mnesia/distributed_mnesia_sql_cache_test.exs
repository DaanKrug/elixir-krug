defmodule Krug.DistributedMnesiaSqlCacheTest do
  use ExUnit.Case
  
  doctest Krug.DistributedMnesiaSqlCache
  
  alias Krug.DistributedMnesiaSqlCache
  
  test "[init_cluster|stop]" do
    cluster_cookie = "my_app_mnesia"
    cluster_name = "my_test_app"
    cluster_ips = "192.168.1.12X "
    ips_separator = "X" 
    tables = [
      :users,
      :log,
      :other_table
    ]  
    my_ip = DistributedMnesiaSqlCache.get_local_wlan_ip()
    node_name = "#{cluster_name}@#{my_ip}" 
                  |> String.to_atom()
    node = :net_kernel.start([node_name, :longnames])
    ok = cluster_cookie
      |> String.to_atom()
      |> Node.set_cookie() 
      
  	assert :ok == node |> Tuple.to_list() |> hd()
  	
    created = cluster_name
                |> DistributedMnesiaSqlCache.init_cluster(cluster_ips,ips_separator,true,tables)
    
    assert created == true
    
    stopped = DistributedMnesiaSqlCache.shutdown()
    
    assert stopped == :ok
  end
  
end