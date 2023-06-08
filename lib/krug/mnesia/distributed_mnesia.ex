defmodule Krug.DistributedMnesia do
 
  @moduledoc """
  Utilitary module to handle Erlang Mnesia Database.
  Mnesia Database has single instance mode and also distributed mode
  that is purpose of this module. Single instance way don't allow us
  to improve horizontal scalability when we need.
  """
  @moduledoc since: "1.1.17"
  
  
  
  alias Krug.MapUtil
  
  
  
  @doc """
  Start the mnesia cluster. To be used on application start.
  
  disc_copies: true for ":disc_copies", false for ":ram_copies" (only ram).
  
  tables: list of map table configurations
  ```elixir
  %{table_name: "users", table_attributes: [:id, :name, :email]}
  ```
  .
  
  connected_nodes: list (of atom) nodes already connected in a cluster.
  """
  def start_mnesia(disc_copies,tables,connected_nodes) do
    :mnesia.stop()
    System.cmd("epmd", ["-daemon"])
    [node()]
      |> :mnesia.create_schema()
    :mnesia.start()
    :extra_db_nodes 
      |> :mnesia.change_config(connected_nodes)
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
        -> true
      true
        -> tables
             |> config_tables3(mode)
    end
  end


  
  defp config_tables3(tables,mode) do
    cond do
      (config_tables4(tables,mode))
        -> tables
             |> tl()
             |> config_tables2(mode)
      true
        -> false 
    end
  end
  
  
  
  defp config_tables4(tables,mode) do
    table = tables
              |> hd()
    table_name = table 
                   |> MapUtil.get(:table_name)
    table_attibutes = table 
                        |> MapUtil.get(:table_attibutes)
    table_name
      |> :mnesia.create_table(attributes: table_attibutes)
      |> config_tables5(mode,table_name)
  end
  
  
  
  defp config_tables5({:aborted, {:node_not_running, _}},_mode,_table_name) do
    false
  end


  
  defp config_tables5({:aborted, {:already_exists,_}},_mode,_table_name) do
    true
  end


  
  defp config_tables5({:atomic,:ok},mode,_table_name) do
    table_name
      |> :mnesia.add_table_copy(node(),mode)
      |> config_tables6()
  end
  
  
  
  defp config_tables6({:atomic,:ok}) do
    true
  end
  
  
  
  defp config_tables6({:aborted,{:already_exists,_,_}}) do
    true
  end
  
  
  
  defp config_tables6({:aborted,_}) do
    false
  end


  
end


