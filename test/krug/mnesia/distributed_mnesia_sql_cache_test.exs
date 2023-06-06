defmodule Krug.DistributedMnesiaSqlCacheTest do
  use ExUnit.Case
  
  doctest Krug.DistributedMnesiaSqlCache
  
  alias Krug.DistributedMnesiaSqlCache
  
  test "[init_cluster|store_data|stop]" do
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
    
    normalized_sql = "select id,name,email from users where email = ? or name = ? "
    params = ["johann@es.cool.de","Johannes Cool"]
    resultset = [
      %{
         id: 203,
         name: "Johannes Cool",
         email: "johann@es.not_cool.pt"
      },
      %{
         id: 308,
         name: "Johannes Not Cool",
         email: "johann@es.cool.de"
      },
      %{
         id: 568,
         name: "Johannes Cool",
         email: "johann@es.cool.de"
      }
    ]
    added = DistributedMnesiaSqlCache.put_cache(
              :users,
              normalized_sql,
              params,
              resultset
            )
    
    assert added == true
    
    stopped = DistributedMnesiaSqlCache.shutdown()
    
    assert stopped == :ok
  end
  
end