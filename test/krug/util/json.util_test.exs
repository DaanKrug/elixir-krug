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
    assert JsonUtil.encode_to_log(map2) 
      == "prefer_band: Guns Roses, name: Johannes Back, age: 57, address: 404 street"
    assert JsonUtil.encode_to_log(map2,substitutions_array) 
      == "Prefered Musical Band: Guns Roses, Name: Johannes Back, Age: 57, Actual Address: 404 street"
  end
  
  
end