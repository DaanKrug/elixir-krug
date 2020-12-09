defmodule Krug.JsonUtilTest do
  use ExUnit.Case
  
  doctest Krug.JsonUtil
  
  alias Krug.JsonUtil
  
  test "[encodeToLog(map,substitutionsArray \\ [])]" do
    map = %{echo: "ping"}
    map2 = %{name: "Johannes Back", age: 57, address: "404 street", prefer_band: "Guns Roses"}
    substitutionsArray = [
    	["prefer_band","Prefered Musical Band"],
    	["name","Name"],
    	["age","Age"],
    	["address","Actual Address"]
    ]
    assert JsonUtil.encodeToLog(map) == "echo: ping"
    assert JsonUtil.encodeToLog(map2) 
      == "prefer_band: Guns Roses, name: Johannes Back, age: 57, address: 404 street"
    assert JsonUtil.encodeToLog(map2,substitutionsArray) 
      == "Prefered Musical Band: Guns Roses, Name: Johannes Back, Age: 57, Actual Address: 404 street"
  end
  
  
end