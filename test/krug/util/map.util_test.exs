defmodule Krug.MapUtilTest do
  use ExUnit.Case
  
  doctest Krug.MapUtil
  
  alias Krug.MapUtil 
  
  test "[test map keys verification]" do
  	map = %{a: 1, b: 2}
    assert Map.has_key?(map,:a) == true
    assert Map.has_key?(map,"a") == false
    assert Map.has_key?(map,:b) == true
    assert Map.has_key?(map,"b") == false
    assert Map.has_key?(map,:c) == false
    assert Map.has_key?(map,"c") == false
  end

  test "[test get(map,key)]" do
    map = %{a: 1, b: 3}
    assert MapUtil.get(map,:a) == 1
    assert MapUtil.get(map,:b) == 3
    assert MapUtil.get(map,:c) == nil
    assert MapUtil.get(map,nil) == nil
    assert MapUtil.get(nil,:a) == nil
    assert MapUtil.get(nil,:b) == nil
    assert MapUtil.get(nil,:c) == nil
    assert MapUtil.get(nil,nil) == nil
  end
  
  test "[test delete(map,key)]" do
  	map = %{a: 1, b: 3}
  	map2 = %{a: 1}
  	map3 = %{b: 3}
  	assert MapUtil.delete(map,:a) == map3
  	assert MapUtil.delete(map,:b) == map2
  	assert MapUtil.delete(map,:c) == map
  	assert MapUtil.delete(map,nil) == map
  	assert MapUtil.delete(nil,:a) == nil
  	assert MapUtil.delete(nil,:b) == nil
  	assert MapUtil.delete(nil,:c) == nil
  	assert MapUtil.delete(nil,nil) == nil
  end
  
  test "[test deleteAll(map,keys)]" do
    map = %{a: 1, b: 3}
  	map2 = %{a: 1}
  	map3 = %{b: 3}
  	assert MapUtil.deleteAll(map,[:a]) == map3
  	assert MapUtil.deleteAll(map,[:b]) == map2
  	assert MapUtil.deleteAll(map,[:c]) == map
  	assert MapUtil.deleteAll(map,[1]) == map
  	assert MapUtil.deleteAll(map,[nil]) == map
  	assert MapUtil.deleteAll(map,[]) == map
  	assert MapUtil.deleteAll(map,nil) == map
  	assert MapUtil.deleteAll(map,[:c,nil]) == map
  	assert MapUtil.deleteAll(nil,[:a]) == nil
  	assert MapUtil.deleteAll(nil,[:b]) == nil
  	assert MapUtil.deleteAll(nil,[:c]) == nil
  	assert MapUtil.deleteAll(nil,[1]) == nil
  	assert MapUtil.deleteAll(nil,[nil]) == nil
  	assert MapUtil.deleteAll(nil,[]) == nil
  	assert MapUtil.deleteAll(nil,nil) == nil
  	assert MapUtil.deleteAll(nil,[:c,nil]) == nil
  	assert MapUtil.deleteAll(map,[:a,:b]) == %{}
  	assert MapUtil.deleteAll(map,[:a,:b,:c]) == %{}
  	assert MapUtil.deleteAll(map,[:a,:b,1]) == %{}
  	assert MapUtil.deleteAll(map,[:a,:b,:c,nil]) == %{}
  	assert MapUtil.deleteAll(map,[:a,:b,nil]) == %{}
  	assert MapUtil.deleteAll(nil,[:a,:b]) == nil
  	assert MapUtil.deleteAll(nil,[:a,:b,:c]) == nil
  	assert MapUtil.deleteAll(nil,[:a,:b,1]) == nil
  	assert MapUtil.deleteAll(nil,[:a,:b,:c,nil]) == nil
  	assert MapUtil.deleteAll(nil,[:a,:b,nil]) == nil
  end
  
  test "[test replace(map,key,newValue)]" do
    map = %{a: 1, b: 3}
    map2 = %{a: 1, b: 1}
    map3 = %{a: 3, b: 3}
    map4 = %{a: 1, b: nil}
    map5 = %{a: 1, b: 3, c: 101}
    assert MapUtil.replace(map,:b,1) == map2
    assert MapUtil.replace(map,:a,3) == map3
    assert MapUtil.replace(map,:b,nil) == map4
    assert MapUtil.replace(nil,:b,1) == nil
    assert MapUtil.replace(map,nil,1) == map
    assert MapUtil.replace(map,:c,101) == map5
  end
  
  
end









