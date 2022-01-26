defmodule Krug.KeyParList do

  @moduledoc """
  Module to handle list of single maps of key/value entries.
  """

  alias Krug.MapUtil



  @doc """
  Obtains a value respective to a ```key``` in keypar list.
  If none of elements contains the key received, return nil. 
  """
  def get(key,list) do
    cond do
      (nil == list or Enum.empty?(list)) -> nil
      true -> get2(key,list)
    end
  end
  
  
  
  @doc false
  defp get2(key,list) do
    element = list |> hd()
    cond do
      (element |> MapUtil.get(:key) == key) 
        -> element |> MapUtil.get(:value)
      true -> get(key,list |> tl())
    end
  end
  
  
  
  @doc """
  Insert a key/value entry in a list. Creates a new entry if not exists
  a respective key. Otherwise replace the existing key/value entry.
  """
  def put(key,value,list) do
    cond do
      (nil == list or Enum.empty?(list)) -> [%{key: key, value: value}]
      true -> put_not_empty(key,value,list,0)
    end
  end



  @doc false
  defp put_not_empty(key,value,list,counter) do
    cond do
      (list |> Enum.at(counter) |> MapUtil.get(:key) == key) 
        -> List.replace_at(list,counter,%{key: key, value: value})
      true -> put_not_empty(key,value,list,counter + 1)
    end
  end



end