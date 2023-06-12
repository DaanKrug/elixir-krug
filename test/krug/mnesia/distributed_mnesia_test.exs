defmodule Krug.DistributedMnesiaTest do
  use ExUnit.Case
  
  doctest Krug.DistributedMnesia
  
  alias Krug.DistributedMnesia
  
  test "[mnesia not started|add_runtime_table]" do
    :mnesia.stop()
    
    runtime_new_table = %{
      table_name: :user_x_runtime, 
      table_attributes: [:id, :name, :email] 
    }
    
    # not running
    created_table_on_runtime = runtime_new_table
                                 |> DistributedMnesia.add_runtime_table()
                                 
    assert created_table_on_runtime == false
    
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
    
    added = DistributedMnesia.store(
              :user_x,
              300,
              objects |> Enum.at(1)
            )
    
    assert added == false
    
    result = DistributedMnesia.load(
               :user_x,
               300
             )
    
    assert result == nil
  end
  
  test "[init_cluster|store|stop|clear|load|select|delete]" do
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
  
  
  
  test "[init_auto_cluster|store|stop|clear|load|select|delete]" do
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
  
  
  
  test "[keep_only_last_used|set_updated_at|add_runtime_table]" do
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
    
    total = :user_x |> DistributedMnesia.count()
    
    assert total == 0
    
    array_params = [
      {
        {:user_x,:"$1",:"$2",:"$3"},# table definition
        [
          {:">",:"$1",0}
        ], #conditions - :id > 0
        [:"$$"] 
      }
    ]
    
    result = :distributed_mnesia_metadata_table 
               |> DistributedMnesia.select(array_params)
    
    assert result == []
    
    object = [
       "Johannes Cool",
       "johann@es.not_cool.pt"
    ]
    
    #######################################
    ## create data
    #######################################
    DistributedMnesia.store(:user_x,1,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x,2,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x,3,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x,4,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x,5,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x,6,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x,7,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x,8,object)
    
    total = :user_x |> DistributedMnesia.count()
    
    assert total == 8
    
    result = :user_x 
               |> DistributedMnesia.select(array_params)
    
    assert result == [
			            [5, "Johannes Cool", "johann@es.not_cool.pt"],
			            [6, "Johannes Cool", "johann@es.not_cool.pt"],
			            [1, "Johannes Cool", "johann@es.not_cool.pt"],
			            [2, "Johannes Cool", "johann@es.not_cool.pt"],
			            [8, "Johannes Cool", "johann@es.not_cool.pt"],
			            [4, "Johannes Cool", "johann@es.not_cool.pt"],
			            [7, "Johannes Cool", "johann@es.not_cool.pt"],
			            [3, "Johannes Cool", "johann@es.not_cool.pt"]
			         ]
    
    
    #######################################
    ## test keep last 4 - by insertion time
    #######################################
    :user_x
      |> DistributedMnesia.keep_only_last_used(4)
      
    total = :user_x |> DistributedMnesia.count()
    
    assert total == 4
    
    result = :user_x
               |> DistributedMnesia.select(array_params)
    
    assert result == [
		               [5, "Johannes Cool", "johann@es.not_cool.pt"],
		               [6, "Johannes Cool", "johann@es.not_cool.pt"],
		               [8, "Johannes Cool", "johann@es.not_cool.pt"],
		               [7, "Johannes Cool", "johann@es.not_cool.pt"]
		             ]
    
    #######################################
    ## recreate data
    #######################################
    cleaned = DistributedMnesia.clear(:user_x)
    
    assert cleaned == true
    
    total = :user_x |> DistributedMnesia.count()
    
    assert total == 0
    
    DistributedMnesia.store(:user_x,1,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x,2,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x,3,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x,4,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x,5,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x,6,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x,7,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x,8,object)
    
    total = :user_x |> DistributedMnesia.count()
    
    assert total == 8
    
    result = :user_x 
               |> DistributedMnesia.select(array_params)
    
    assert result == [
		               [5, "Johannes Cool", "johann@es.not_cool.pt"],
		               [6, "Johannes Cool", "johann@es.not_cool.pt"],
		               [1, "Johannes Cool", "johann@es.not_cool.pt"],
		               [2, "Johannes Cool", "johann@es.not_cool.pt"],
		               [8, "Johannes Cool", "johann@es.not_cool.pt"],
		               [4, "Johannes Cool", "johann@es.not_cool.pt"],
		               [7, "Johannes Cool", "johann@es.not_cool.pt"],
		               [3, "Johannes Cool", "johann@es.not_cool.pt"]
		             ]
    
    #######################################
    ## update usage time of some entries
    #######################################
    :timer.sleep(100)
    :user_x
      |> DistributedMnesia.set_updated_at(1)
    :user_x
      |> DistributedMnesia.set_updated_at(3)
    :user_x
      |> DistributedMnesia.set_updated_at(5)
    
    total = :user_x |> DistributedMnesia.count()
    
    assert total == 8
    
    result = :user_x 
               |> DistributedMnesia.select(array_params)
    
    assert result == [
		               [5, "Johannes Cool", "johann@es.not_cool.pt"],
		               [6, "Johannes Cool", "johann@es.not_cool.pt"],
		               [1, "Johannes Cool", "johann@es.not_cool.pt"],
		               [2, "Johannes Cool", "johann@es.not_cool.pt"],
		               [8, "Johannes Cool", "johann@es.not_cool.pt"],
		               [4, "Johannes Cool", "johann@es.not_cool.pt"],
		               [7, "Johannes Cool", "johann@es.not_cool.pt"],
		               [3, "Johannes Cool", "johann@es.not_cool.pt"]
		             ]
    
    #######################################
    ## now should be keep entries with
    ## ids 1,3,5 and 8
    #######################################
    :user_x
      |> DistributedMnesia.keep_only_last_used(4)
      
    total = :user_x |> DistributedMnesia.count()
    
    assert total == 4
    
    result = :user_x 
               |> DistributedMnesia.select(array_params)
    
    assert result == [
		               [5, "Johannes Cool", "johann@es.not_cool.pt"],
		               [1, "Johannes Cool", "johann@es.not_cool.pt"],
		               [8, "Johannes Cool", "johann@es.not_cool.pt"],
		               [3, "Johannes Cool", "johann@es.not_cool.pt"]
		             ]
		             
	##########################
	# run time table tests
	##########################
	runtime_new_table = %{
      table_name: :user_x_runtime, 
      table_attributes: [:id, :name, :email] 
    }
    
    created_table_on_runtime = runtime_new_table
                                 |> DistributedMnesia.add_runtime_table()
                                 
    assert created_table_on_runtime == true	
    
    created_table_on_runtime = runtime_new_table
                                 |> DistributedMnesia.add_runtime_table()
                                 
    assert created_table_on_runtime == true	    
    
    DistributedMnesia.store(:user_x_runtime,1,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x_runtime,2,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x_runtime,3,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x_runtime,4,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x_runtime,5,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x_runtime,6,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x_runtime,7,object)
    :timer.sleep(10)
    DistributedMnesia.store(:user_x_runtime,8,object)
    
    total = :user_x_runtime |> DistributedMnesia.count()
    
    assert total == 8
    
    array_params2 = [
      {
        {:user_x_runtime,:"$1",:"$2",:"$3"},# table definition
        [
          {:">",:"$1",0}
        ], #conditions - :id > 0
        [:"$$"] 
      }
    ]
    
    result = :user_x_runtime 
               |> DistributedMnesia.select(array_params2)
    
    assert result == [
		               [5, "Johannes Cool", "johann@es.not_cool.pt"],
		               [6, "Johannes Cool", "johann@es.not_cool.pt"],
		               [1, "Johannes Cool", "johann@es.not_cool.pt"],
		               [2, "Johannes Cool", "johann@es.not_cool.pt"],
		               [8, "Johannes Cool", "johann@es.not_cool.pt"],
		               [4, "Johannes Cool", "johann@es.not_cool.pt"],
		               [7, "Johannes Cool", "johann@es.not_cool.pt"],
		               [3, "Johannes Cool", "johann@es.not_cool.pt"]
		             ]
      
  end
  
  
  
end