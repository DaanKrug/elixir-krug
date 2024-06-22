defmodule Krug.DistributedMnesiaCloner do

  @moduledoc false
  
  alias Krug.MapUtil
  
  def add_table_copy(table,storage_mode) do
    table
      |> MapUtil.get(:table_name)
      |> :mnesia.add_table_copy(node(),storage_mode)
  end
  
end