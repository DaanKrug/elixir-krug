defmodule Krug.DistributedMnesia do
 
  @moduledoc """
  Utilitary module to handle Erlang Mnesia Database.
  Mnesia Database has single instance mode and also distributed mode
  that is purpose of this module. Single instance way don't allow us
  to improve horizontal scalability when we need.
  """
  @moduledoc since: "1.1.17"
  
  
  
  alias Krug.StringUtil
  
  @ip_regexp ~r/^\d+\.\d+\.\d+\.\d+$/
  
  
    
  
  @doc """
  Start the mnesia cluster. To be used on application start.
  
  ## Example
  
  ```elixir
  defmodule <Your_App_Main_Module_Name>.Application do
  
    @moduledoc false
  
    use Application
  
    alias Krug.DistributedMnesia


    def start(_type, _args) do
      Supervisor.start_link(children(), opts())
    end
  
    defp children() do
  	  [
  	    ...
  	    <Your_App_Main_Module_Name>.DistributedMnesiaTaskStarter, # calls Krug.DistributedMnesia.init_cluster(...)
  	    ...
  	  ]
    end
  
    defp opts() do 
  	  [strategy: :one_for_one, name: <Your_App_Main_Module_Name>.Supervisor]
    end 
    
  end
  ```
  
  ```elixir
  defmodule <Your_App_Main_Module_Name>.DistributedMnesiaConfigTaskStarter do
    def child_spec(opts) do
      %{id: __MODULE__,start: {__MODULE__, :start_link, [opts]}}
    end
  
    def start_link(opts) do
      Supervisor.start_link([{<Your_App_Main_Module_Name>.DistributedMnesiaConfigTask,opts}], strategy: :one_for_one)
    end
  end
  ```
  
  ```elixir
  defmodule <Your_App_Main_Module_Name>.DistributedMnesiaConfigTask do
 
    use Task
    alias Krug.DistributedMnesia
 
    def start_link(opts) do
      Task.start_link(__MODULE__, :run, [opts])
    end

    def run(_opts) do
      cluster_cookie = "my_app_mnesia_cookie_5435434876876"
      cluster_name = "my_test_app"
      cluster_ips = "10.0.0.2!10.0.0.135!10.0.0.241!10.0.0.127"
      ips_separator = "!"
      tables = [
      	:users,
      	:my_annotations,
      	:my_contacts,
      	:my_schedules
      ]
      
      # set cookie and cluster name to allow remote connection
      # to permit the cluster formation
      cluster_name
        |> String.to_atom()
        |> Node.start()
      cluster_cookie
        |> String.to_atom()
        |> Node.set_cookie()
      
      # wait X seconds before start - it will try improve that all
      # cluster machines will be with the application deployed before the first 
      # machine start the connection to anothers.
  	  :timer.sleep(5000) 
      
      cluster_name
        |> DistributedMnesia.init_cluster(cluster_ips,ips_separator,true,tables)
    end
  
  end
  ```
  """
  def init_cluster(cluster_name,cluster_ips,ips_separator \\ "|",disc_copies \\ false,tables \\ []) do
    cluster_ips
      |> StringUtil.trim()
      |> StringUtil.split(ips_separator)
      |> Enum.filter(
           fn 
             ip -> String.match?(ip,@ip_regexp) 
           end
         )
      |> Enum.each(
           fn 
             ip ->
               node = "#{cluster_name}@#{ip}"
                        |> String.to_atom()
               Logger.info("Trying to connect to mnesia node #{node}")
               Node.connect(node)
           end
         )
    disc_copies
      |> connect_mnesia(tables)
  end
  
  
  
  defp start(disc_copies,tables) do
    :mnesia.start()
    :extra_db_nodes
      |> :mnesia.change_config(Node.list())
    cond do
      (disc_copies)
        -> tables
             |> config_tables(:disc_copies)
      true
        -> tables
             |> config_tables(:ram_copies)
    end 
  end


  
  defp config_tables(tables,mode) do
    :schema
      |> :mnesia.change_table_copy_type(node(),mode)
    tables
      |> config_tables2(mode)
  end


  
  defp config_tables2(tables,mode) do
    cond do
      (Enum.empty?(tables))
        -> :ok
      true
        -> tables
             |> config_tables3(mode)
    end
  end


  
  defp config_tables3(tables,mode) do
    tables
      |> hd()
      |> :mnesia.add_table_copy(node(),mode)
    tables
      |> tl()
      |> config_tables2(mode)
  end
  
end


