defmodule Krug.DistributedMnesiaCreator do

  @moduledoc false
  
  require Logger
  alias Krug.MapUtil
  
  
  def create_table(table,storage_mode) do
    table_name = table
                   |> MapUtil.get(:table_name)
    table_attributes = table
                         |> MapUtil.get(:table_attributes)
    table_name
      |> :mnesia.create_table(
           [
             attributes: table_attributes,
             type: :set
           ]
         )
      |> add_table_index(
           storage_mode,
           table_name,
           table_attributes 
             |> hd()
         )
  end
  
  defp add_table_index({:aborted, {:node_not_running, _}},_storage_mode,table_name,_table_index) do
    Logger.info(
      """
      [Krug.DistributedMnesiaCreator] => 
      [#{node()}] not running mnesia node: table #{table_name} not created.
      """
    )
  end

  defp add_table_index({:aborted, {:already_exists,_}},storage_mode,table_name,table_index) do
    table_name
      |> :mnesia.add_table_index(table_index)
    table_name 
      |> :mnesia.change_table_copy_type(node(),storage_mode)
    table_name
      |> :mnesia.add_table_copy(node(),storage_mode)
  end

  defp add_table_index({:atomic,:ok},storage_mode,table_name,table_index) do
    table_name
      |> :mnesia.add_table_index(table_index)
    table_name 
      |> :mnesia.change_table_copy_type(node(),storage_mode)
    table_name
      |> :mnesia.add_table_copy(node(),storage_mode)
  end
  
end