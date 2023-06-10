defmodule Krug.DistributedMnesiaSqlCacheTest do
  use ExUnit.Case
  
  doctest Krug.DistributedMnesiaSqlCache
  
  alias Krug.DistributedMnesiaSqlCache
  
  test "[mnesia not started]" do
    :mnesia.stop()
    
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
    
    assert added == false
    
    result = DistributedMnesiaSqlCache.load_from_cache(
               :users,
               normalized_sql,
               params
             )
    
    assert result == nil
    
    cleaned = DistributedMnesiaSqlCache.clear_cache(:users)
    
    assert cleaned == false
  end
  
  test "[init_cluster|put_cache|load_from_cache|clear_cache|stop]" do
    cluster_cookie = "echo"
    cluster_name = "echo"
    cluster_ips = "192.168.1.12X "
    ips_separator = "X" 
    table_names = [
      :users,
      :log,
      :other_table
    ]  
    
    created = cluster_name
                |> DistributedMnesiaSqlCache.init_cluster(
                     cluster_cookie,
                     cluster_ips,
                     ips_separator,
                     true,
                     table_names,
                     100
                   )
    
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
    
    result = DistributedMnesiaSqlCache.load_from_cache(
               :users,
               normalized_sql,
               params
             )
    
    assert result |> length() == 3
    
    cleaned = DistributedMnesiaSqlCache.clear_cache(:users)
    
    assert cleaned == true
    
    result = DistributedMnesiaSqlCache.load_from_cache(
               :users,
               normalized_sql,
               params
             )
    
    assert result == nil
  end
  
  
  
  test "[init_auto_cluster|put_cache|load_from_cache|clear_cache|stop]" do
    cluster_cookie = "echo"
    cluster_name = "echo"
    table_names = [
      :users,
      :log,
      :other_table
    ]  
    
    created = cluster_name
                |> DistributedMnesiaSqlCache.init_auto_cluster(
                     cluster_cookie,
                     true,
                     table_names,
                     100
                   )
    
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
    
    result = DistributedMnesiaSqlCache.load_from_cache(
               :users,
               normalized_sql,
               params
             )
    
    assert result |> length() == 3
    
    cleaned = DistributedMnesiaSqlCache.clear_cache(:users)
    
    assert cleaned == true
    
    result = DistributedMnesiaSqlCache.load_from_cache(
               :users,
               normalized_sql,
               params
             )
    
    assert result == nil
  end


  
  test "[init_auto_cluster|put_cache with limit]" do
    cluster_cookie = "echo"
    cluster_name = "echo"
    table_names = [
      :users,
      :log,
      :other_table
    ]  
    
    amount_to_keep = 3
    
    created = cluster_name
                |> DistributedMnesiaSqlCache.init_auto_cluster(
                     cluster_cookie,
                     true,
                     table_names,
                     100
                   )
    
    assert created == true
    
    #######
    # add 1
    #######
    added = DistributedMnesiaSqlCache.put_cache(
              :users,
              "select A",
              ["johann@es.cool.de","Johannes Cool"],
              [%{id: 1,name: "Johannes Cool",email: "johann@es.not_cool.pt"}],
              amount_to_keep
            )
    
    assert added == true
    
    result = DistributedMnesiaSqlCache.load_from_cache(
               :users,
               "select A",
               ["johann@es.cool.de","Johannes Cool"]
             )
    
    assert result |> length() == 1
    
    #######
    # add 2
    #######
    added = DistributedMnesiaSqlCache.put_cache(
              :users,
              "select B",
              ["johann@es.cool.de","Johannes Cool"],
              [%{id: 2,name: "Johannes Cool",email: "johann@es.not_cool.pt"}],
              amount_to_keep
            )
    
    assert added == true
    
    result = DistributedMnesiaSqlCache.load_from_cache(
               :users,
               "select B",
               ["johann@es.cool.de","Johannes Cool"]
             )
    
    assert result |> length() == 1
    
    #######
    # add 3
    #######
    added = DistributedMnesiaSqlCache.put_cache(
              :users,
              "select C",
              ["johann@es.cool.de","Johannes Cool"],
              [%{id: 3,name: "Johannes Cool",email: "johann@es.not_cool.pt"}],
              amount_to_keep
            )
    
    assert added == true
    
    result = DistributedMnesiaSqlCache.load_from_cache(
               :users,
               "select C",
               ["johann@es.cool.de","Johannes Cool"]
             )
    
    assert result |> length() == 1
    
    #######
    # add 4
    #######
    added = DistributedMnesiaSqlCache.put_cache(
              :users,
              "select D",
              ["johann@es.cool.de","Johannes Cool"],
              [%{id: 4,name: "Johannes Cool",email: "johann@es.not_cool.pt"}],
              amount_to_keep
            )
    
    assert added == true
    
    result = DistributedMnesiaSqlCache.load_from_cache(
               :users,
               "select D",
               ["johann@es.cool.de","Johannes Cool"]
             )
    
    assert result |> length() == 1
    
    #########
    # removed
    #########
    result = DistributedMnesiaSqlCache.load_from_cache(
               :users,
               "select A",
               ["johann@es.cool.de","Johannes Cool"]
             )
    
    assert result == nil
    
    #######
    # update to keep
    #######
    result = DistributedMnesiaSqlCache.load_from_cache(
               :users,
               "select B",
               ["johann@es.cool.de","Johannes Cool"]
             )
             
    assert result == [%{id: 2,name: "Johannes Cool",email: "johann@es.not_cool.pt"}]
    
    #######
    # add 5
    #######
    added = DistributedMnesiaSqlCache.put_cache(
              :users,
              "select E",
              ["johann@es.cool.de","Johannes Cool"],
              [%{id: 5,name: "Johannes Cool",email: "johann@es.not_cool.pt"}],
              amount_to_keep
            )
    
    assert added == true
    
    result = DistributedMnesiaSqlCache.load_from_cache(
               :users,
               "select E",
               ["johann@es.cool.de","Johannes Cool"]
             )
    
    assert result |> length() == 1
    
    #########
    # removed
    #########
    result = DistributedMnesiaSqlCache.load_from_cache(
               :users,
               "select C",
               ["johann@es.cool.de","Johannes Cool"]
             )
    
    assert result == nil
    
    #######
    # keeped because updated
    #######
    result = DistributedMnesiaSqlCache.load_from_cache(
               :users,
               "select B",
               ["johann@es.cool.de","Johannes Cool"]
             )
             
    assert result == [%{id: 2,name: "Johannes Cool",email: "johann@es.not_cool.pt"}]
    
  end
  
  
  
end


