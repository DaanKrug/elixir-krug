defmodule ExApp.MnesiaTestTask do
 
  use Task
  alias Krug.DistributedMnesia
  alias Krug.SanitizerUtil

  def start_link(opts) do
    Task.start_link(__MODULE__, :run, [opts])
  end

  def run(_opts) do
    cluster_cookie = "app_k"  # Use same value on machines A and B if you want an [A,B] cluster 
    cluster_name = "app_k" # Use same value on machines A and B if you want an [A,B] cluster
    cluster_timeout = 100  # connection time out in milliseconds for connecting remote nodes (clustering)
    
    # Let's define data tables for be used on cluster. Use same definition
    # on machines A and B (and others intended be in same cluster)
    tables = [
      %{
        table_name: :user,  # Table name definition, should be an ATOM  
        table_attributes: [ # Table columns definition, should be ATOMs
          :id, # The first column is the "id" column, and the index column no matter wich name used (by convention)
          :name, # Sample data column
          :email # Sample data column
        ]  
      }
    ]  
    
    # init_auto_cluster: Will discover and try to connect to all network machines in network range /24
    # respective to your network, example from  192.168.1.0 to 192.168.255.255
    # the condition is these machines should have the same "cluster_cookie" value defined above
    started = cluster_name
      |> DistributedMnesia.init_auto_cluster(
           cluster_cookie,
           true,
           tables,
           cluster_timeout
         )
        
    ["started => ",started] |> IO.inspect() 
    :mnesia.system_info() |> IO.inspect()
    :schema
      |> :mnesia.table_info(:master_nodes) 
      |> IO.inspect()
  
  	timeout = 10000
  	:timer.sleep(timeout)
    run_loop()
  end
  
  # Testing only "insert" and "load" methods. In documentation you could seed 
  # all other CRUD equivalent methods and others.   
  # "store" method works as an "update" replacing previous data for table ":user"
  # for a row wich "id" column wich value equalt to "300". 
  # The "id" column is always the first table row defined, by convention.
  defp run_loop() do
    try do
      sleep_time = 10000
      
      # Machine B inserting data
      DistributedMnesia.store(
        :user,
        300,
        [
          "Johannes Pá #{SanitizerUtil.generate_random(10)}",
          "johanes@pa.#{SanitizerUtil.generate_random(10)}"
        ]
      )
      
      # Data inserted by local node in machine B
      result = DistributedMnesia.load(
                 :user,
                 300
               )
               
      # Data inserted by remote node in machine B
      result_remote = DistributedMnesia.load(
                        :user,
                        200
                      )
               
      ["[user_id = 200] result node remote =>", result] |> IO.inspect()
      ["[user_id = 300] result node local => ", result_remote] |> IO.inspect()
      
      :timer.sleep(sleep_time)
      run_loop()
    rescue
      _ -> rescue_run_loop()
    end
  end
  
  defp rescue_run_loop() do
  	timeout = 15000
  	IO.puts("MnesiaTestTask: Rescued from Error: going sleep for #{timeout} miliseconds before retry.")
    :timer.sleep(timeout)
    run_loop()
  end
    
end


