defmodule Krug.MnesiaUtil do

  @moduledoc """
  Utilitary module to handle some mnesia operations
  """
  @moduledoc since: "1.1.17"
  
  
    
  @doc """
  Provides encapsulated behaviour for data storage
  using transaction for call
  ```elixir
  data = [table_name | [id_row | data_row]]
  data = data |> List.to_tuple() # result in {table_name,id_row,data_row[0] ... data_row[n]}
  :mnesia.write(data)
  ```
  
  Works in key value storage style, where "id_row" is the key, and "data_row"
  the value. Both values could be of any data type. "table_name" should be an atom.
  This run fine for normal mnesia usage way (storing objects as in database row).
  
  Return true or false.
  
  Requires mnesia already be started. 
  """
  def store(table_name,id_row,data_row) do
    write_data = fn ->
      [table_name | [id_row | data_row]]
        |> List.to_tuple()
        |> :mnesia.write()
    end
    write_data
      |> :mnesia.transaction()
      |> put_cache_result()
  end
  
  
  
  @doc """
  Provides encapsulated behaviour for data storage
  using transaction for call
  ```elixir
  :mnesia.write({table_name,id_row,data_row})
  ```
  
  Works in key value storage style, where "id_row" is the key, and "data_row"
  the value. Both values could be of any data type. "table_name" should be an atom.
  This is intended to be more key-value object storage (like Redis), where
  "data_row" could be anything from a simple string to a list, a map, a sql
  resultset, and many others.
  
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
      |> load_from_cache_result()
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
    true
  end
  
  
  
  ##########################################
  ### store functions
  ########################################## 
  defp put_cache_result({:atomic, :ok}) do
    true  
  end
  
  
  
  defp put_cache_result(error) do
    error |> IO.inspect()
    false  
  end
  


  ########################################## 
  ### load functions
  ########################################## 
  defp load_from_cache_result({:atomic,key_entry_array}) do
    cond do
      (nil == key_entry_array
        or Enum.empty?(key_entry_array))
          -> nil
      true
        -> key_entry_array
             |> hd()
    end
  end
  
  
  
  defp load_from_cache_result(_) do
    nil
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


