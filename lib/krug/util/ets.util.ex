defmodule Krug.EtsUtil do

  @moduledoc """
  Utilitary module to secure handle ETS in memory data.
  """



  @doc """
  Creates a new ets table whit received ```ets_key``` and
  visibility. Case the table already exists, do not create a new,
  only return the existing ets_key.
  
  SHOULD BE created in a process that act a task, living across
  the runtime of application. One good example is a Ecto repository.
  
  ```elixir
  defmodule MyApp.App.Repo do 
    
    use Ecto.Repo, otp_app: :my_app, adapter: Ecto.Adapters.MyXQL
    ...
    alias Krug.EtsUtil
    
    def init(_type, config) do
      ...
      EtsUtil.new(:my_ets_key_atom_identifier)
      {:ok, config}
    end
  
  end
  ``
  
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
  
  Equivalent to ```:ets.new(ets_key, [:set, :private, :named_table])```
  
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
  def new(ets_key,visibility \\ "public",read_concurrency \\ true) do
    cond do
      (ets_table_exists(ets_key)) -> ets_key
      true -> :ets.new(ets_key,get_ets_options(visibility,read_concurrency))
    end
  end
  
  
  
  @doc """
  Deletes a existing ets table whit received ```ets_key```.
  Case the table don't exists, return true.
  
  The garbage collector do not destroy the ets tables. We need
  explicitly make it. Do not forget of call ```EtsUtil.delete(:my_key)```
  before of terminate the proccess that has created it whit ```EtsUtil.new(...)```.
  
  Doesn't acceppt string as key. ```EtsUtil.delete("key")``` will fail, as
  in :ets direct call.
  
  Equivalent to ```:ets.delete(ets_key)```.
  
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
  def delete(ets_key) do
    cond do
      (!ets_table_exists(ets_key)) -> true
      true -> :ets.delete(ets_key)
    end
  end
  
  
  
  @doc """
  Store a key/value par in ets table identified by received ```ets_key```.
  Case the table don't exists, return false.
  
  If a old value exists and couldn't be replaced, return false.
  
  Equivalent to ```:ets.insert(ets_key,{key,value})```.
  
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
  def store_in_cache(ets_key,key,value) do
    cond do
      (!ets_table_exists(ets_key)) 
        -> false
      true -> :ets.insert(ets_key,{key,value})
    end
  end
  
 
  
  @doc """
  Read a value relative to a key ```key``` stored in a ets table whit received ```ets_key```.
  Case the table don't exists, return nil.
  
  If the key don't exists, return nil.
  
  Equivalent to ```:ets.lookup(ets_key,key) |> Tuple.to_list() |> Enum.at(1)```
  
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
  def read_from_cache(ets_key,key) do
    cond do
      (!ets_table_exists(ets_key)) -> nil
      true -> :ets.lookup(ets_key,key) 
                |> read_from_cache2()
    end
  end
  
  
  
  @doc """
  Delete a key/value par in ets table identified by received ```ets_key```.
  Case the table don't exists, return true.
  
  If the ```key``` don't exists in ets table or its value is nil, return true.
  
  Equivalent to ```:ets.delete(ets_key,key)```
  
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
  def remove_from_cache(ets_key,key) do
    cond do
      (!ets_table_exists(ets_key)) -> true
      true -> :ets.delete(ets_key,key)
    end
  end



  defp read_from_cache2(tuple_array) do
    cond do
      (nil == tuple_array or Enum.empty?(tuple_array)) -> nil
      true -> tuple_array |> hd() |> elem(1)
    end
  end
  


  defp ets_table_exists(ets_key) do
    :ets.whereis(ets_key) != :undefined
  end



  defp get_ets_options(visibility,read_concurrency) do
    cond do
      (visibility == "protected") 
        -> [:set, :protected, :named_table, {:read_concurrency, read_concurrency}]
      (visibility == "private") 
        -> [:set, :private, :named_table, {:read_concurrency, read_concurrency}]
      true 
        -> [:set, :public, :named_table, {:read_concurrency, read_concurrency}]
    end
  end



end