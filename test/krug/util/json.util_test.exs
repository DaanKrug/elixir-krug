defmodule Krug.JsonUtilTest do
  use ExUnit.Case
  
  doctest Krug.JsonUtil
  
  alias Krug.JsonUtil
  
  test "[encode_to_log(map,substitutions_array \\ [])]" do
    map = %{echo: "ping"}

    map2 = %{name: "Johannes Back", age: 57, address: "404 street", prefer_band: "Guns Roses"}

    substitutions_array = [
    	["prefer_band","Prefered Musical Band"],
    	["name","Name"],
    	["age","Age"],
    	["address","Actual Address"]
    ]
    
    assert JsonUtil.encode_to_log(map) == "echo: ping"

    result = JsonUtil.encode_to_log(map2)
               |> String.split(", ")
               |> Enum.sort()

    assert result == [
                       "prefer_band: Guns Roses", 
                       "name: Johannes Back", 
                       "age: 57", 
                       "address: 404 street"
                     ]
                       |> Enum.sort()

    result = JsonUtil.encode_to_log(map2,substitutions_array)
               |> String.split(", ")
               |> Enum.sort()

    assert result == [
                       "Prefered Musical Band: Guns Roses", 
                       "Name: Johannes Back", 
                       "Age: 57", 
                       "Actual Address: 404 street"
                     ]
                       |> Enum.sort()
  end
  
end
