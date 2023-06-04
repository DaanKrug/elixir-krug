defmodule Krug.DistributedMnesiaSqlCacheTest do
  use ExUnit.Case
  
  doctest Krug.DistributedMnesiaSqlCache
  
  alias Krug.DistributedMnesiaSqlCache
  
  test "[init_cluster|stop]" do
    cluster_cookie = "my_app_mnesia_cookie_5435434876876"
    cluster_name = "my_test_app"
    cluster_ips = "127.0.0.1X "
    ips_separator = "X" 
    tables = [
      :users,
      :log,
      :other_table
    ]  
    
    System.cmd("epmd", ["-daemon"])
    :net_kernel.start(
      "#{cluster_name |> String.to_atom()}@127.0.0.1", 
      :longnames
    )
    
    cluster_cookie
      |> String.to_atom()
      |> Node.set_cookie()  
  	:timer.sleep(5000) 
    created = cluster_name
                |> DistributedMnesiaSqlCache.init_cluster(cluster_ips,ips_separator,true,tables)
    
    assert created == true
    
    stopped = DistributedMnesiaSqlCache.shutdown()
    
    assert stopped == :ok
  end
  
end