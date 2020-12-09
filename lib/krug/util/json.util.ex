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
  iex > Krug.JsonUtil.encodeToLog(map)
  "echo: ping"
  ```
  ```elixir 
  iex > map = %{name: "Johannes Backend", age: 57, address: "404 street", prefer_band: "Guns Roses"}
  iex > Krug.JsonUtil.encodeToLog(map)
  "prefer_band: Guns Roses, name: Johannes Backend, age: 57, address: 404 street"
  ```
  ```elixir 
  iex > map = %{name: "Johannes Backend", age: 57, address: "404 street", prefer_band: "Guns Roses"}
  iex > substitutionsArray = [["prefer_band","Prefered Musical Band"],["name","Name"],["age","Age"],
                              ["address","Actual Address"]]
  iex > Krug.JsonUtil.encodeToLog(map,substitutionsArray)
  "Prefered Musical Band: Guns Roses, Name: Johannes Backend, Age: 57, Actual Address: 404 street"
  ```
  """
  def encodeToLog(map,substitutionsArray \\[]) do
    cond do
      (nil == map) -> ""
      true -> encodeMapToLog(map,substitutionsArray)
    end
  end


  
  defp encodeMapToLog(map,substitutionsArray) do
    Poison.encode!(map)
      |> StringUtil.replace(":",": ")
      |> StringUtil.replace(",",", ") 
      |> StringUtil.replace("\"","")
      |> StringUtil.replace("{","")
      |> StringUtil.replace("}","")
      |> makeSubstitutions(substitutionsArray)
  end
  
  
  
  defp makeSubstitutions(json,array) do
    cond do
      (nil == array or length(array) == 0) -> json
      true -> makeSubstitutions(makeSubstitution(json,hd(array)),tl(array))
    end
  end



  defp makeSubstitution(json,arrayElement) do
    json |> StringUtil.replace(arrayElement |> Enum.at(0),arrayElement |> Enum.at(1))
  end


       
end