defmodule Krug.JsonUtil do

  @moduledoc """
  Utilitary module to make objects (maps) can be transformated. 
  """

  alias Krug.StringUtil



  @doc """
  Transform a Map relative to a CRUD object into
  a string format to be logged/stored in table log on database,
  in format text similar a json string.

  ## Examples

  ```elixir 
  iex > map = %{echo: "ping"}
  iex > Krug.JsonUtil.encode_to_log(map)
  "echo: ping"
  ```
  ```elixir 
  iex > map = %{name: "Johannes Backend", age: 57, address: "404 street", prefer_band: "Guns Roses"}
  iex > Krug.JsonUtil.encode_to_log(map)
  "prefer_band: Guns Roses, name: Johannes Backend, age: 57, address: 404 street"
  ```
  ```elixir 
  iex > map = %{name: "Johannes Backend", age: 57, address: "404 street", prefer_band: "Guns Roses"}
  iex > substitutions_array = [["prefer_band","Prefered Musical Band"],["name","Name"],["age","Age"],
                              ["address","Actual Address"]]
  iex > Krug.JsonUtil.encode_to_log(map,substitutions_array)
  "Prefered Musical Band: Guns Roses, Name: Johannes Backend, Age: 57, Actual Address: 404 street"
  ```
  """
  def encode_to_log(map,substitutions_array \\[]) do
    cond do
      (nil == map) -> ""
      true -> encodeMap_to_log(map,substitutions_array)
    end
  end


  
  defp encodeMap_to_log(map,substitutions_array) do
    Poison.encode!(map)
      |> StringUtil.replace(":",": ",true)
      |> StringUtil.replace(",",", ",true) 
      |> StringUtil.replace("\"","",true)
      |> StringUtil.replace("{","",true)
      |> StringUtil.replace("}","",true)
      |> make_substitutions(substitutions_array)
  end
  
  
  
  defp make_substitutions(json,array) do
    cond do
      (nil == array or Enum.empty?(array)) -> json
      true -> json |> make_substitution(hd(array)) |> make_substitutions(tl(array))
    end
  end



  defp make_substitution(json,array_element) do
    json |> StringUtil.replace(array_element |> hd(),array_element |> tl() |> hd(),true)
  end


       
end