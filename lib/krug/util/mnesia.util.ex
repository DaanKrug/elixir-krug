defmodule Krug.MnesiaUtil do

  @moduledoc """
  Utilitary module to handle some mnesia operations
  """
  @moduledoc since: "1.1.17"
  
  @doc """
  Provides encapsulated behaviour for data storage
  using transaction for call
  ```elixir
  :mnesia.write({table_name,id_row,data_row})
  ```
  
  Works in key value storage style, where "id_row" is the key, and "data_row"
  the value. Both values could be of any data type. "table_name" should be an atom.
  
  Return true or false.
  
  Requires mnesia already be started. 
  """
  def put_cache(table_name,id_row,data_row) do
    write_data = fn ->
      :mnesia.write({table_name,id_row,data_row})
    end
    write_data
      |> :mnesia.transaction()
      |> put_cache_result()
  end
  
  
  
  @doc """
  Provides encapsulated behaviour for load the stored key value
  using transaction for
  ```elixir
  :mnesia.read({table_name,id_row})
  ```
  for an key "id_row" from an table "table_name". Return the stored value or nil.
  
  Requires mnesia already be started. 
  """
  def load_from_cache(table_name,id_row) do
    read_data = fn ->
      :mnesia.read({table_name,id_row})
    end
    read_data
      |> :mnesia.transaction()
      |> load_from_cache_result(table_name,id_row)
  end
  
  
  
  @doc """
  Provides cache functionality to clear cached results of all key value rows
  from a table "table_name". Return true or false.
  
  Requires mnesia already be started. 
  """
  def clear_cache(table_name) do
    table_name
	  |> :mnesia.clear_table()
      |> clear_cache_result()
  end
  
  
  
  ##########################################
  ### store functions
  ########################################## 
  defp put_cache_result({:atomic, :ok}) do
    true  
  end
  
  
  
  defp put_cache_result(_) do
    false  
  end
  


  ########################################## 
  ### load functions
  ########################################## 
  defp load_from_cache_result({:atomic,key_entry_array},table_name,id) do
    cond do
      (Enum.empty?(key_entry_array))
        -> nil
      true
        -> key_entry_array
             |> hd()
             |> load_from_cache_result2(table_name,id)
    end
  end
  
  
  
  defp load_from_cache_result(_,_table_name,_id) do
    nil
  end
  
  
  
  defp load_from_cache_result2(key_entry,table_name,id) do
    {table_name_entry,id_entry,resultset} = key_entry
    cond do
      (nil == resultset
        or table_name_entry != table_name
          or id_entry != id)
            -> nil
      true
        -> resultset
    end
  end  
  
  
  
  ########################################## 
  ### clear cache functions
  ########################################## 
  defp clear_cache_result({:atomic,:ok}) do
    true
  end
  
  
  
  defp clear_cache_result(_) do
    false
  end


  
end


