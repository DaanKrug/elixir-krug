defmodule Krug.StructUtil do

  @moduledoc """
  Utilitary secure module to provide mechanisms to handle some
  complex operations on structs.
  """
  
  alias Krug.StringUtil



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
  	cond do
      (nil == tuple or (tuple_size(tuple) < 2)) -> nil
      true -> tuple |> elem(1)
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
      (nil == list or Enum.empty?(list)) -> false
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
      (nil == list or nil == values or Enum.empty?(list)) -> false
      true -> list_contains_one_of2(list,values)
    end
  end
  
  
  
  @doc """
  Compare 2 lists and return if all elements from first are present on second
  - (if are equals). Return true or false
  """
  @doc since: "1.1.31"
  def contains_all(list_1,list_2) do
    cond do
      (nil == list_1 or nil == list_2)
        -> false
      (Enum.empty?(list_1) or Enum.empty?(list_2))
        -> false
      (length(list_1) != length(list_2))
        -> false
      true
        -> contains_all2(list_1,list_2)
    end
  end
  	  
  	  
  
  @doc """
  Return a key par value from a list of key_par strings in format ["key=value","key=value"].
  
  If the key or the list is nil/empty return nil.

  ## Examples

  ```elixir 
  iex > Krug.StructUtil.get_key_par_value_from_list(nil,nil)
  nil
  ```
  ```elixir 
  iex > Krug.StructUtil.get_key_par_value_from_list("name",nil)
  nil
  ```
  ```elixir 
  iex > Krug.StructUtil.get_key_par_value_from_list(nil,"name")
  nil
  ```
  ```elixir 
  iex > Krug.StructUtil.get_key_par_value_from_list([],"name")
  nil
  ```
  ```elixir 
  iex > list = ["name=Johannes Backend","email=johannes@has.not.email"]
  iex > Krug.StructUtil.get_key_par_value_from_list("",list)
  nil
  ```
  ```elixir 
  iex > list = ["name=Johannes Backend","email=johannes@has.not.email"]
  iex > Krug.StructUtil.get_key_par_value_from_list("keyNotExist",list)
  nil
  ```
  ```elixir 
  iex > list = ["name=Johannes Backend","email=johannes@has.not.email"]
  iex > Krug.StructUtil.get_key_par_value_from_list("name",list)
  "Johannes Backend"
  ```
  ```elixir 
  iex > list = ["name=Johannes Backend","email=johannes@has.not.email"]
  iex > Krug.StructUtil.get_key_par_value_from_list("email",list)
  "johannes@has.not.email"
  ```
  ```elixir 
  iex > list = [" name = Johannes Backend ","email=johannes@has.not.email"]
  iex > Krug.StructUtil.get_key_par_value_from_list("email",list)
  "Johannes Backend"
  ```
  """
  @doc since: "0.2.1"
  def get_key_par_value_from_list(key,list) do
    cond do
      (nil == key or nil == list or StringUtil.trim(key) == "") -> nil
      true -> get_key_par_value_from_list2(StringUtil.trim(key),list)
    end
  end
  
  
  
  defp get_key_par_value_from_list2(key,list) do
    cond do
      (Enum.empty?(list)) -> nil
      true -> get_key_par_value_from_list3(key,list)
    end
  end
  
  
  
  defp get_key_par_value_from_list3(key,list) do
    value_from_key = get_key_value_from_string(key,hd(list))
    cond do
      (nil != value_from_key) -> value_from_key
      true -> get_key_par_value_from_list2(key,tl(list))
    end
  end
  
  
  
  defp get_key_value_from_string(key,string) do
    cond do
      (nil == string or !(String.contains?(string,"="))) -> nil
      true -> get_key_value_from_string2(key,string)
    end
  end
  
  
  
  defp get_key_value_from_string2(key,string) do
    key_value_array = StringUtil.split(string,"=",true)
    cond do
      (key_value_array |> hd() |> StringUtil.trim() == key) 
        -> key_value_array |> tl() |> hd() |> StringUtil.trim()
      true -> nil
    end
  end
  
  
  
  defp list_contains_one_of2(list,values) do
    cond do
      (Enum.empty?(values)) -> false
      (Enum.member?(list,hd(values))) -> true
      true -> list_contains_one_of2(list,tl(values))
    end
  end
  
  
  
  defp contains_all2(list_1,list_2) do
    cond do
      (Enum.empty?(list_1))
        -> true
      (!(list_contains(list_2,list_1 |> hd()))) 
        -> false
      true 
        -> list_1
             |> tl()
             |> contains_all2(list_2)
    end
  end
  
  
  
end


