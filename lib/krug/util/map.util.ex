defmodule Krug.MapUtil do

  @moduledoc """
  Utilitary safe module to manipulate Map structs.
  """



  @doc """
  Obtain a value from a Map, respective to a key.
  
  If the map or key received is nil/invalid return nil.
  
  If key don't exists in map, return nil.

  ## Example

  ```elixir 
  iex > map = %{a: 1, b: 3}
  iex > Krug.MapUtil.get(map,:a)
  1
  ```
  """
  def get(map,key) do
    cond do
      (nil == map or nil == key) -> nil
      (Map.has_key?(map,key)) -> Map.get(map,key)
      (Map.has_key?(map,"#{key}")) -> map["#{key}"]
      true -> nil
    end
  end


  
  @doc """
  Delete a value from a Map, respective to a key.
  
  If receive a nil/invalid/empty key, return the map received.
  
  If receive a nil map or received map is invalid or don't
  contains the key, return the map received.  
  
  ## Example

  ```elixir 
  iex > map = %{a: 1, b: 3}
  iex > Krug.MapUtil.delete(map,:a)
  %{b: 3}
  ```
  """
  def delete(map,key) do
    cond do
      (nil == map or nil == key) -> map
      (Map.has_key?(map,key)) -> Map.delete(map,key)
      (Map.has_key?(map,"#{key}")) -> Map.delete(map,"#{key}")
      true -> map
    end
  end


  
  @doc """
  Delete all values from a Map, respective to received keys in list/enum.
  
  If receive a nil/invalid/empty keys list/enum, return the map received.
  
  Ignore keys that are invalid or don't exist in received map.
  
  ## Example

  ```elixir 
  iex > map = %{a: 1, b: 3, c: 10}
  iex > Krug.MapUtil.delete_all(map,[:a,:c,:d])
  %{b: 3}
  ```
  """
  def delete_all(map,keys) do
    cond do
      (nil == map or nil == keys or Enum.empty?(keys)) -> map
      true -> delete(map,hd(keys)) |> delete_all(tl(keys))
    end
  end


  
  @doc """
  Replace/update a value from a Map, respective to a key.
    
  If receive a nil/invalid key, return the map received.

  If receive a nil map or received map is invalid or don't
  contains the key, return the map received.  
  
  If receives a valid value and the key received is valid and not 
  exists in map, then add the new key and value to map.

  ## Examples

  ```elixir 
  iex > map = %{a: 1, b: 3}
  iex > Krug.MapUtil.replace(map,:a,3)
  %{a: 3, b: 3}
  ```
  ```elixir 
  iex > map = %{a: 1, b: 3}
  iex > Krug.MapUtil.replace(map,:c,101)
  %{a: 3, b: 3, c: 101}
  ```
  """
  def replace(map,key,newValue) do
  	cond do
      (nil == map or nil == key) -> map
      (Map.has_key?(map,key)) -> Map.replace!(map,key,newValue)
      (Map.has_key?(map,"#{key}")) -> Map.replace!(map,"#{key}",newValue)
      (nil == newValue) -> map
      true -> map |> Map.put(key,newValue)
    end
  end


  
end