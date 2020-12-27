defmodule Krug.EtsUtil do

  @moduledoc """
  Utilitary module to secure handle ETS in memory data.
  """



  @doc """
  Creates a new ets table whit received ```session_key``` and
  visibility. Case the table already exists, do not create a new,
  only return the existing session_key.
  
  Visibility can be one of ["public","protected","private"] as 
  in ets documentation. By default the value is "protected", as
  defined in :ets machanism. If a not valid value for visibilty is received,
  the default value is assumed.
  
  Use "private" for the values be acessible only in module where the ETS table
  is declared. Escope "protected" allows access to all modules in same
  supervisor tree (a same Thread processes analogy), and "public"
  allows access to any process of any supervisor tree (concurrent Threads
  access equivalency). 
  
  The garbage collector do not destroy the ets tables. We need
  explicitly make it. Do not forget of call ```EtsUtil.delete(:my_key)```
  before of terminate the proccess that has created it whit ```EtsUtil.new(...)```.
  
  Equivalent to ```:ets.new(session_key, [:set, :private, :named_table])```
  
  Doesn't acceppt string as key. ```EtsUtil.new("key")``` will fail, as
  in :ets direct call.
  
  ## Examples
  
  ```elixir
  iex > EtsUtil.new("echo")
  ** (ArgumentError) argument error
  ```
  ```elixir
  iex > EtsUtil.new(:echo)
  :echo
  ```
  ```elixir
  iex > EtsUtil.new(:echo,"protected")
  :echo
  ```
  ```elixir
  iex > EtsUtil.new(:echo,"private")
  :echo
  ```
  ```elixir
  iex > EtsUtil.new(:echo,"public")
  :echo
  ```
  """
  def new(session_key,visibility \\ "protected") do
    cond do
      (ets_table_exists(session_key)) -> session_key
      (visibility == "public") -> :ets.new(session_key, [:set, :public, :named_table])
      (visibility == "private") -> :ets.new(session_key, [:set, :private, :named_table])
      true -> :ets.new(session_key,get_ets_options())
    end
  end
  
  
  
  @doc """
  Deletes a existing ets table whit received ```session_key```.
  Case the table don't exists, return true.
  
  The garbage collector do not destroy the ets tables. We need
  explicitly make it. Do not forget of call ```EtsUtil.delete(:my_key)```
  before of terminate the proccess that has created it whit ```EtsUtil.new(...)```.
  
  Doesn't acceppt string as key. ```EtsUtil.delete("key")``` will fail, as
  in :ets direct call.
  
  Equivalent to ```:ets.delete(session_key)```.
  
  ## Examples
  
  ```elixir
  iex > EtsUtil.delete("echo")
  ** (ArgumentError) argument error
  ```
  ```elixir
  iex > EtsUtil.delete(:echo)
  true
  ```
  ```elixir
  iex > EtsUtil.delete(:keyThatNotExists)
  true
  ```
  """
  def delete(session_key) do
    cond do
      (!ets_table_exists(session_key)) -> true
      true -> :ets.delete(session_key)
    end
  end
  
  
  
  @doc """
  Store a key/value par in ets table identified by received ```session_key```.
  Case the table don't exists, return false.
  
  If a old value exists and couldn't be replaced, return false.
  
  Equivalent to ```:ets.insert(session_key,{key,value})```.
  
  ## Examples
  
  ```elixir
  iex > EtsUtil.store_in_cache(:keyThatDontExists,"ping","pong")
  false
  ```
  ```elixir
  iex > EtsUtil.new(:echo)
  iex > EtsUtil.store_in_cache(:echo,"ping","pong")
  true
  ```
  ```elixir
  iex > EtsUtil.new(:echo)
  iex > EtsUtil.store_in_cache(:echo,"ping","pong")
  iex > EtsUtil.store_in_cache(:echo,"ping","foo")
  true
  ```
  """
  def store_in_cache(session_key,key,value) do
    cond do
      (!ets_table_exists(session_key)) -> false
      (!remove_from_cache(session_key,key)) -> false
      true -> :ets.insert(session_key,{key,value})
    end
  end
  
  
  
  @doc """
  Read a value relative to a key ```key``` stored in a ets table whit received ```session_key```.
  Case the table don't exists, return nil.
  
  If the key don't exists, return nil.
  
  Equivalent to ```:ets.lookup(session_key,key) |> Tuple.to_list() |> Enum.at(1)```
  
  ## Examples
  
  ```elixir
  iex > EtsUtil.read_from_cache(:keyThatDontExists,"ping")
  nil
  ```
  ```elixir
  iex > EtsUtil.new(:echo)
  iex > EtsUtil.read_from_cache(:echo,"ping")
  nil
  ```
  ```elixir
  iex > EtsUtil.new(:echo)
  iex > EtsUtil.store_in_cache(:echo,"ping","pong")
  iex > EtsUtil.read_from_cache(:echo,"ping")
  "pong"
  ```
  ```elixir
  iex > EtsUtil.new(:echo)
  iex > EtsUtil.store_in_cache(:echo,"ping","pong")
  iex > EtsUtil.store_in_cache(:echo,"ping","foo")
  iex > EtsUtil.read_from_cache(:echo,"ping")
  "foo"
  ```
  """
  def read_from_cache(session_key,key) do
    tuple_array = cond do
      (!ets_table_exists(session_key)) -> nil
      true -> :ets.lookup(session_key,key)
    end
    element = cond do
      (nil == tuple_array or length(tuple_array) < 1) -> nil
      true -> tuple_array |> Enum.at(0)
    end
    cond do
      (nil == element) -> nil
      true -> element |> elem(1) 
    end
  end
  
  
  
  @doc """
  Delete a key/value par in ets table identified by received ```session_key```.
  Case the table don't exists, return true.
  
  If the ```key``` don't exists in ets table or its value is nil, return true.
  
  Equivalent to ```:ets.delete(session_key,key)```
  
  ## Examples
  
  ```elixir
  iex > EtsUtil.remove_from_cache(:keyThatDontExists,"ping")
  true
  ```
  ```elixir
  iex > EtsUtil.new(:echo)
  iex > EtsUtil.remove_from_cache(:echo,"ping")
  true
  ```
  ```elixir
  iex > EtsUtil.new(:echo)
  iex > EtsUtil.store_in_cache(:echo,"ping","pong")
  iex > EtsUtil.remove_from_cache(:echo,"ping")
  true
  ```
  """
  def remove_from_cache(session_key,key) do
    cond do
      (!ets_table_exists(session_key)) -> true
      true -> :ets.delete(session_key,key)
    end
  end
  
  
  
  defp ets_table_exists(session_key) do
    :ets.whereis(session_key) != :undefined
  end



  defp get_ets_options() do
    [
      :set, 
      :protected, 
      :named_table,
      write_concurrency: true,
      read_concurrency: true
    ]
  end



end