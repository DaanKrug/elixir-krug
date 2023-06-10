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
                     tables,
                     100
                   )
    
    assert created == true
    
    cleaned = DistributedMnesia.clear(:user_x)
    
    assert cleaned == true
    
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
    
    total = :user_x |> DistributedMnesia.count()
    
    assert total == 3
    
    array_params = [
      {
        {:user_x,:"$1",:"$2",:"$3"},# table definition
        [
          {:"==",:"$2","Johannes Cool"}
        ], #conditions - :name = "Johannes Cool"
        [:"$$"] 
      }
    ]
    
    result = :user_x 
               |> DistributedMnesia.select(array_params)
    
    assert result == [
                       [200, "Johannes Cool", "johann@es.not_cool.pt"], 
                       [400, "Johannes Cool", "johann@es.cool.de"]
                     ]
                     
    array_params = [
      {
        {:user_x,:"$1",:"$2",:"$3"},# table definition
        [
          {:"==",:"$3","johann@es.cool.de"}
        ], #conditions - :email = "johann@es.cool.de"
        [:"$$"] 
      }
    ]
    
    result = :user_x 
               |> DistributedMnesia.select(array_params)
    
    assert result == [
                       [300, "Johannes Not Cool", "johann@es.cool.de"], 
                       [400, "Johannes Cool", "johann@es.cool.de"]
                     ]
                     
    total = :user_x |> DistributedMnesia.count()
    
    assert total == 3
    
    deleted = :user_x |> DistributedMnesia.delete(300)
    
    assert deleted == true
    
    total = :user_x |> DistributedMnesia.count()
    
    assert total == 2
    
    result = :user_x 
               |> DistributedMnesia.select(array_params)
    
    assert result == [
                       [400, "Johannes Cool", "johann@es.cool.de"]
                     ]
    
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
                     tables,
                     100
                   )
    
    assert created == true
    
    cleaned = DistributedMnesia.clear(:user_x)
    
    assert cleaned == true
    
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
    
    total = :user_x |> DistributedMnesia.count()
    
    assert total == 3
    
    array_params = [
      {
        {:user_x,:"$1",:"$2",:"$3"},# table definition
        [
          {:"==",:"$2","Johannes Cool"}
        ], #conditions - :name = "Johannes Cool"
        [:"$$"] 
      }
    ]
    
    result = :user_x 
               |> DistributedMnesia.select(array_params)
    
    assert result == [
                       [200, "Johannes Cool", "johann@es.not_cool.pt"], 
                       [400, "Johannes Cool", "johann@es.cool.de"]
                     ]
                     
    array_params = [
      {
        {:user_x,:"$1",:"$2",:"$3"},# table definition
        [
          {:"==",:"$3","johann@es.cool.de"}
        ], #conditions - :email = "johann@es.cool.de"
        [:"$$"] 
      }
    ]
    
    result = :user_x 
               |> DistributedMnesia.select(array_params)
    
    assert result == [
                       [300, "Johannes Not Cool", "johann@es.cool.de"], 
                       [400, "Johannes Cool", "johann@es.cool.de"]
                     ]
                     
    array_params2 = [
      {
        {:distributed_mnesia_metadata_table,:"$1",:"$2",:"$3",:"$4"},# table definition
        [
          {:"==",:"$2",:user_x}
        ], 
        [[:"$1",:"$2",:"$3"]] 
      }
    ]
    
    result = :distributed_mnesia_metadata_table 
               |> DistributedMnesia.select(array_params2)
    
    assert result == [
                       ["user_x_400", :user_x, 400], 
                       ["user_x_200", :user_x, 200], 
                       ["user_x_300", :user_x, 300]
                     ]
                     
    total = :user_x |> DistributedMnesia.count()
    
    assert total == 3
    
    deleted = :user_x |> DistributedMnesia.delete(300)
    
    assert deleted == true
    
    total = :user_x |> DistributedMnesia.count()
    
    assert total == 2
    
    result = :user_x 
               |> DistributedMnesia.select(array_params)
    
    assert result == [
                       [400, "Johannes Cool", "johann@es.cool.de"]
                     ]
    
    cleaned = DistributedMnesia.clear(:user_x)
    
    assert cleaned == true
    
    result = DistributedMnesia.load(
               :user_x,
               200
             )
    
    assert result == nil
    
    result = :distributed_mnesia_metadata_table 
               |> DistributedMnesia.select(array_params2)
    
    assert result == []
    
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