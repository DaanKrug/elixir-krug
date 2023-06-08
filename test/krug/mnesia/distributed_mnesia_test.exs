defmodule Krug.DistributedMnesiaTest do
  use ExUnit.Case
  
  doctest Krug.DistributedMnesia
  
  alias Krug.DistributedMnesia
  alias Krug.MapUtil
  
  test "[init_cluster|store_data|stop]" do
    cluster_cookie = "echo"
    cluster_name = "echo"
    cluster_ips = "192.168.1.12X "
    ips_separator = "X" 
    tables = [
      %{
        table_name: :users, 
        table_attributes: [:id, :name, :email] 
      }
    ]  
    
    created = cluster_name
                |> DistributedMnesia.init_cluster(
                     cluster_cookie,
                     cluster_ips,
                     ips_separator,
                     true,
                     tables
                   )
    
    assert created == true
    
    objects = [
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
    
    result = DistributedMnesia.load(
               :users,
               objects |> Enum.at(0) |> MapUtil.get(:id)
             )
    
    assert result == nil
    
    result = DistributedMnesia.load(
               :users,
               objects |> Enum.at(1) |> MapUtil.get(:id)
             )
    
    assert result == nil
    
    result = DistributedMnesia.load(
               :users,
               objects |> Enum.at(2) |> MapUtil.get(:id)
             )
    
    assert result == nil
    
    added = DistributedMnesia.store(
              :users,
              objects |> Enum.at(0) |> MapUtil.get(:id),
              objects |> Enum.at(0)
            )
    
    assert added == true
    
    result = DistributedMnesia.load(
               :users,
               objects |> Enum.at(0) |> MapUtil.get(:id)
             )
    
    assert result == %{email: "johann@es.not_cool.pt", id: 203, name: "Johannes Cool"}
    
    added = DistributedMnesia.store(
              :users,
              objects |> Enum.at(1) |> MapUtil.get(:id),
              objects |> Enum.at(1)
            )
    
    assert added == true
    
    result = DistributedMnesia.load(
               :users,
               objects |> Enum.at(1) |> MapUtil.get(:id)
             )
    
    assert result == %{email: "johann@es.cool.de", id: 308, name: "Johannes Not Cool"}
    
    added = DistributedMnesia.store(
              :users,
              objects |> Enum.at(2) |> MapUtil.get(:id),
              objects |> Enum.at(2)
            )
    
    assert added == true
    
    result = DistributedMnesia.load(
               :users,
               objects |> Enum.at(2) |> MapUtil.get(:id)
             )
    
    assert result == %{email: "johann@es.cool.de", id: 568, name: "Johannes Cool"}
    
    cleaned = DistributedMnesia.clear(:users)
    
    assert cleaned == true
    
    result = DistributedMnesia.load(
               :users,
               objects |> Enum.at(0) |> MapUtil.get(:id)
             )
    
    assert result == nil
    
    result = DistributedMnesia.load(
               :users,
               objects |> Enum.at(1) |> MapUtil.get(:id)
             )
    
    assert result == nil
    
    result = DistributedMnesia.load(
               :users,
               objects |> Enum.at(2) |> MapUtil.get(:id)
             )
    
    assert result == nil
    
  end
  
end