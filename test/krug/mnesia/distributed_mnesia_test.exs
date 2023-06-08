defmodule Krug.DistributedMnesiaTest do
  use ExUnit.Case
  
  doctest Krug.DistributedMnesia
  
  alias Krug.DistributedMnesia
  
  
  test "[init_cluster|store_data|stop]" do
    cluster_cookie = "echo"
    cluster_name = "echo"
    cluster_ips = "192.168.1.12X "
    ips_separator = "X" 
    tables = [
      %{
        table_name: :user_x, 
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
      [
         "Johannes Cool",
         "johann@es.not_cool.pt"
      ],
      [
         "Johannes Not Cool",
         "johann@es.cool.de"
      ],
      [
         "Johannes Cool",
         "johann@es.cool.de"
      ]
    ]
    
    result = DistributedMnesia.load(
               :user_x,
               200
             )
    
    assert result == nil
    
    result = DistributedMnesia.load(
               :user_x,
               300
             )
    
    assert result == nil
    
    result = DistributedMnesia.load(
               :user_x,
               400
             )
    
    assert result == nil
    
    added = DistributedMnesia.store(
              :user_x,
              200,
              objects |> Enum.at(0)
            )
    
    assert added == true
    
    result = DistributedMnesia.load(
               :user_x,
               200
             )
    
    assert result == {:user_x, 200, "Johannes Cool", "johann@es.not_cool.pt"}
    
    added = DistributedMnesia.store(
              :user_x,
              300,
              objects |> Enum.at(1)
            )
    
    assert added == true
    
    result = DistributedMnesia.load(
               :user_x,
               300
             )
    
    assert result == {:user_x, 300, "Johannes Not Cool", "johann@es.cool.de"}
    
    added = DistributedMnesia.store(
              :user_x,
              400,
              objects |> Enum.at(2)
            )
    
    assert added == true
    
    result = DistributedMnesia.load(
               :user_x,
               400
             )
    
    assert result == {:user_x, 400, "Johannes Cool", "johann@es.cool.de"}
    
    cleaned = DistributedMnesia.clear(:user_x)
    
    assert cleaned == true
    
    result = DistributedMnesia.load(
               :user_x,
               200
             )
    
    assert result == nil
    
    result = DistributedMnesia.load(
               :user_x,
               300
             )
    
    assert result == nil
    
    result = DistributedMnesia.load(
               :user_x,
               400
             )
    
    assert result == nil
    
  end
  
  
  
  test "[init_auto_cluster|store_data|stop]" do
    cluster_cookie = "echo"
    cluster_name = "echo"
    tables = [
      %{
        table_name: :user_x, 
        table_attributes: [:id, :name, :email] 
      }
    ]  
    
    created = cluster_name
                |> DistributedMnesia.init_auto_cluster(
                     cluster_cookie,
                     true,
                     tables
                   )
    
    assert created == true
    
    objects = [
      [
         "Johannes Cool",
         "johann@es.not_cool.pt"
      ],
      [
         "Johannes Not Cool",
         "johann@es.cool.de"
      ],
      [
         "Johannes Cool",
         "johann@es.cool.de"
      ]
    ]
    
    result = DistributedMnesia.load(
               :user_x,
               200
             )
    
    assert result == nil
    
    result = DistributedMnesia.load(
               :user_x,
               300
             )
    
    assert result == nil
    
    result = DistributedMnesia.load(
               :user_x,
               400
             )
    
    assert result == nil
    
    added = DistributedMnesia.store(
              :user_x,
              200,
              objects |> Enum.at(0)
            )
    
    assert added == true
    
    result = DistributedMnesia.load(
               :user_x,
               200
             )
    
    assert result == {:user_x, 200, "Johannes Cool", "johann@es.not_cool.pt"}
    
    added = DistributedMnesia.store(
              :user_x,
              300,
              objects |> Enum.at(1)
            )
    
    assert added == true
    
    result = DistributedMnesia.load(
               :user_x,
               300
             )
    
    assert result == {:user_x, 300, "Johannes Not Cool", "johann@es.cool.de"}
    
    added = DistributedMnesia.store(
              :user_x,
              400,
              objects |> Enum.at(2)
            )
    
    assert added == true
    
    result = DistributedMnesia.load(
               :user_x,
               400
             )
    
    assert result == {:user_x, 400, "Johannes Cool", "johann@es.cool.de"}
    
    cleaned = DistributedMnesia.clear(:user_x)
    
    assert cleaned == true
    
    result = DistributedMnesia.load(
               :user_x,
               200
             )
    
    assert result == nil
    
    result = DistributedMnesia.load(
               :user_x,
               300
             )
    
    assert result == nil
    
    result = DistributedMnesia.load(
               :user_x,
               400
             )
    
    assert result == nil
  end
  
end