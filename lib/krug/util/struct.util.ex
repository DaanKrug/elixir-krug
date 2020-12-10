defmodule Krug.StructUtil do

  @moduledoc """
  Utilitary secure module to provide mechanisms to handle some
  complex operations on structs.
  """



  @doc """
  Return a value from a tuple, ignoring the key.
  
  If the tuple is nil or value of key is nil/empty return nil.
  
  If tuple contains only the key, return nil.

  ## Examples

  ```elixir 
  iex > tuple = {:ok}
  iex > Krug.StructUtil.get_value_from_tuple(tuple)
  nil
  ```
  ```elixir 
  iex > tuple = {:ok,nil}
  iex > Krug.StructUtil.get_value_from_tuple(tuple)
  nil
  ```
  ```elixir 
  iex > tuple = {:ok,[1,2,3]}
  iex > Krug.StructUtil.get_value_from_tuple(tuple)
  [1,2,3]
  ```
  ```elixir 
  iex > tuple = {:ok,%{a: 1, b: 2, c: 3}}
  iex > Krug.StructUtil.get_value_from_tuple(tuple)
  %{a: 1, b: 2, c: 3}
  ```
  ```elixir 
  iex > tuple = {:error,"Operation Error"}
  iex > Krug.StructUtil.get_value_from_tuple(tuple)
  "Operation Error"
  ```
  """
  def get_value_from_tuple(tuple) do
  	array = cond do
      (nil == tuple) -> nil
      true -> Tuple.to_list(tuple)
    end
    cond do
      (nil == array or length(array) == 0) -> nil
      true -> array |> Enum.at(1)
    end
  end
  
  
  
  @doc """
  Verify if a value is present on a list or not.
  
  If the list is nil/empty return false.

  ## Examples

  ```elixir 
  iex > list = []
  iex > Krug.StructUtil.list_contains(list,nil)
  false
  ```
  ```elixir 
  iex > list = nil
  iex > Krug.StructUtil.list_contains(list,nil)
  false
  ```
  ```elixir 
  iex > list = [nil]
  iex > Krug.StructUtil.list_contains(list,nil)
  true
  ```
  ```elixir 
  iex > list = [1,%{a: 1, b: 2},"",nil,[1,2,3],5]
  iex > Krug.StructUtil.list_contains(list,"")
  true
  ```
  ```elixir 
  iex > list = [1,%{a: 1, b: 2},"",nil,[1,2,3],5]
  iex > Krug.StructUtil.list_contains(list," ")
  false
  ```
  ```elixir 
  iex > list = [1,%{a: 1, b: 2},"",nil,[1,2,3],5]
  iex > Krug.StructUtil.list_contains(list,%{a: 1, b: 2})
  true
  ```
  ```elixir 
  iex > list = [1,%{a: 1, b: 2},"",nil,[1,2,3],5]
  iex > Krug.StructUtil.list_contains(list,%{a: 1, b: 5})
  false
  ```
  """
  def list_contains(list,value) do
    cond do
      (nil == list or length(list) == 0) -> false
      true -> (Enum.member?(list,value))
    end
  end
  
  
  
  @doc """
  Verify if one value of a list ```values``` is present on a list or not.
  Return true when find first match. If none value of ```values``` is present on list,
  return false.
  
  If the list is nil/empty return false.

  ## Examples

  ```elixir 
  iex > list = []
  iex > values = []
  iex > Krug.StructUtil.list_contains_one_of(list,values)
  false
  ```
  ```elixir 
  iex > list = [1,2,4,6]
  iex > values = [5,7,8]
  iex > Krug.StructUtil.list_contains_one_of(list,values)
  false
  ```
  ```elixir 
  iex > list = [1,2,4,6]
  iex > values = [5,7,8,"A",%{a: 1, b: 3},9,6]
  iex > Krug.StructUtil.list_contains_one_of(list,values)
  true
  ```
  ```elixir 
  iex > list = [1,2,4,6]
  iex > values = [5,7,8,"A",%{a: 1, b: 3},9]
  iex > Krug.StructUtil.list_contains_one_of(list,values)
  false
  ```
  ```elixir 
  iex > list = [1,2,4,6,%{a: 1, b: 3}]
  iex > values = [5,7,8,"A",%{a: 1, b: 3},9]
  iex > Krug.StructUtil.list_contains_one_of(list,values)
  true
  ```
  ```elixir 
  iex > list = [1,2,4,6,%{a: 1, b: 3}]
  iex > values = [5,7,8,"A",%{a: 1, b: 5},9]
  iex > Krug.StructUtil.list_contains_one_of(list,values)
  false
  ```
  """
  def list_contains_one_of(list,values) do
    cond do
      (nil == list or length(list) == 0 or nil == values or length(values) == 0) -> false
      (Enum.member?(list,hd(values))) -> true
      true -> list_contains_one_of(list,tl(values))
    end
  end
  
  
  
end









