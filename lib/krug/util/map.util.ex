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
      (nil == map 
        or nil == key) 
          -> nil
      (Map.has_key?(map,key)) 
        -> map
             |> Map.get(key)
      (Map.has_key?(map,"#{key}")) 
        -> map["#{key}"]
      true 
        -> nil
    end
  end
  
  
  
  @doc """
  Obtain a value from a Map, respective to a ATOM key.
  
  Use only for performatic reasons, and you are sure that key exists on map and is from atom type.
  ## Example

  ```elixir 
  iex > map = %{a: 1, b: 3}
  iex > Krug.MapUtil.get_by_atom_key(map,:a)
  1
  ```
  ```elixir 
  iex > map = %{a: 1, b: 3}
  iex > Krug.MapUtil.get_by_atom_key(map,:c)
  throws an exception
  ```
  ```elixir 
  iex > map = %{a: 1, b: 3}
  iex > Krug.MapUtil.get_by_atom_key(map,"a")
  throws an exception
  ```
  """
  @doc since: "1.1.42"
  def get_by_atom_key(map,key) do
    Map.get(map,key)
  end
  
  
  
  @doc """
  Obtain a value from a Map, respective to a STRING key.
  
  Use only for performatic reasons, and you are sure that key exists on map and is from string type.
  ## Example

  ```elixir 
  iex > map = %{"a" => 1, "b" => 3}
  iex > Krug.MapUtil.get_by_string_key(map,"a")
  1
  ```
  ```elixir 
  iex > map = %{"a" => 1, "b" => 3}
  iex > Krug.MapUtil.get_by_string_key(map,"c")
  throws an exception
  ```
  ```elixir 
  iex > map = %{"a" => 1, "b" => 3}
  iex > Krug.MapUtil.get_by_string_key(map,:a)
  throws an exception
  ```
  """
  @doc since: "1.1.42"
  def get_by_string_key(map,key) do
    map["#{key}"]
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
      (nil == map 
        or nil == key) 
          -> map
      (Map.has_key?(map,key)) 
        -> map
             |> Map.delete(key)
      (Map.has_key?(map,"#{key}")) 
        -> map
             |> Map.delete("#{key}")
      true 
        -> map
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
      (nil == map 
        or nil == keys 
          or Enum.empty?(keys)) 
            -> map
      true 
        -> map
             |> delete(keys |> hd()) 
             |> delete_all(keys |> tl())
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
  def replace(map,key,new_value) do
  	cond do
      (nil == map 
        or nil == key) 
          -> map
      (Map.has_key?(map,key)) 
        -> map
             |> Map.replace!(key,new_value)
      (Map.has_key?(map,"#{key}")) 
        -> map
             |> Map.replace!("#{key}",new_value)
      true 
      	-> map 
      	     |> Map.put(key,new_value)
    end
  end
  
  
  
  @doc """
  Replace/update a value from a Map, respective to a ATOM key.
  
  Use only for performatic reasons, and you are sure that key exists on map and is from atom type.
  ## Examples

  ```elixir 
  iex > map = %{a: 1, b: 3}
  iex > Krug.MapUtil.replace_by_atom_key(map,:a,3)
  %{a: 3, b: 3}
  ```
  ```elixir 
  iex > map = %{a: 1, b: 3}
  iex > Krug.MapUtil.replace_by_atom_key(map,:c,101)
  throws an exception
  ```
  ```elixir 
  iex > map = %{a: 1, b: 3}
  iex > Krug.MapUtil.replace_by_atom_key(map,"b",101)
  throws an exception
  ```
  """
  @doc since: "1.1.42"
  def replace_by_atom_key(map,key,new_value) do
  	Map.replace!(map,key,new_value)
  end


  
  @doc """
  Replace/update a value from a Map, respective to a STRING key.
  
  Use only for performatic reasons, and you are sure that key exists on map and is from string type.
  ## Examples

  ```elixir 
  iex > map = %{"a" => 1, "b" => 3}
  iex > Krug.MapUtil.replace_by_string_key(map,"a",3)
  %{"a" => 3, "b" => 3}
  ```
  ```elixir 
  iex > map = %{"a" => 1, "b" => 3}
  iex > Krug.MapUtil.replace_by_string_key(map,"c",3)
  throws an exception
  ```
  ```elixir 
  iex > map = %{"a" => 1, "b" => 3}
  iex > Krug.MapUtil.replace_by_string_key(map,:b,3)
  throws an exception
  ```
  """
  @doc since: "1.1.42"
  def replace_by_string_key(map,key,new_value) do
  	Map.replace!(map,"#{key}",new_value)
  end
  
  
    
end