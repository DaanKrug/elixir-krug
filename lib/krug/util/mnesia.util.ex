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
  
  
  
  @doc """
  Provides encapsulated behaviour for load the LAST stored key value
  using transaction for
  ```elixir
  :mnesia.last(table_name)
  ```
  for an table "table_name". Return the stored value or nil.
  
  Requires mnesia already be started. 
  """
  @doc since: "1.1.25"
  def load_last(table_name) do
    read_data = fn ->
      table_name
        |> :mnesia.last()
    end
    read_data
      |> :mnesia.transaction()
  end
  
  
  
  @doc """
  Provides encapsulated behaviour for load the FIRST stored key value
  using transaction for
  ```elixir
  :mnesia.first(table_name)
  ```
  for an table "table_name". Return the stored value or nil.
  
  Requires mnesia already be started. 
  """
  @doc since: "1.1.25"
  def load_first(table_name) do
    read_data = fn ->
      table_name
        |> :mnesia.first()
    end
    read_data
      |> :mnesia.transaction()
  end
  
  
  
  @doc """
  Executes a "select" operation against a "table_name" filtering by
  "match_spec" and "limit"
  
  Requires mnesia already be started. 
  """
  @doc since: "1.1.25"
  def select(table_name,map_pattern) do
    count = table_name 
              |> :mnesia.table_info(:size)
    cond do
      (count == 0)
        -> []
      true
        -> table_name
             |> select2(map_pattern)
    end
  end
  
  
  
  @doc """
  Executes a "count" operation against a "table_name".
  
  Requires mnesia already be started. 
  """
  @doc since: "1.1.25"
  def count(table_name) do
    table_name 
      |> :mnesia.table_info(:size)
  end
  
  
  
  @doc """
  Provides encapsulated behaviour for delete stored key value
  using transaction for
  ```elixir
  :mnesia.delete(table_name,id_row,:write)
  ```
  for an table "table_name". Return :ok.
  
  Requires mnesia already be started. 
  """
  @doc since: "1.1.25"
  def delete(table_name,id_row) do
    delete_data = fn ->
      table_name
        |> :mnesia.delete(id_row,:write)
    end
    delete_data
      |> :mnesia.transaction()
  end
  
  
  
  ##########################################
  ### store functions
  ########################################## 
  defp put_cache_result({:atomic, :ok}) do
    true  
  end
  
  
  
  defp put_cache_result(_error) do
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

  
  
  ###########################################
  # Select operations
  ###########################################
  defp select2(table_name,array_params) do
    read_data = fn ->
      table_name
        |> :mnesia.select(array_params)
    end
    read_data
      |> :mnesia.transaction()
      |> select_result()
  end



  defp select_result({:atomic,match_array}) do
    match_array
  end
  
  
  
  defp select_result({[match],_continuation}) do
    [match]
  end
  
  
  
  defp select_result(:"$_end_of_table") do
    []
  end
  
  
  
end


