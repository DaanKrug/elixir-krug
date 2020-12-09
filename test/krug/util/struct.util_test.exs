defmodule Krug.StructUtilTest do
  use ExUnit.Case
  
  doctest Krug.StructUtil
  
  alias Krug.StructUtil
  
  test "[getValueFromTuple(tuple)]" do
    assert StructUtil.getValueFromTuple({:ok}) == nil
    assert StructUtil.getValueFromTuple({:ok,nil}) == nil
    assert StructUtil.getValueFromTuple({:ok,[]}) == []
    assert StructUtil.getValueFromTuple({:ok,%{}}) == %{}
    assert StructUtil.getValueFromTuple({:ok, [1,2,3]}) == [1,2,3]
    assert StructUtil.getValueFromTuple({:ok, %{a: 1, b: 2, c: 3}}) == %{a: 1, b: 2, c: 3}
    assert StructUtil.getValueFromTuple({:error, %{a: 1, b: 2, c: 3}}) == %{a: 1, b: 2, c: 3}
    assert StructUtil.getValueFromTuple({:error, "Error Message"}) == "Error Message"
  end
  
  test "[listContains(list,value)]" do
    list = [1,%{a: 1, b: 2},"",nil,[1,2,3],5]
    assert StructUtil.listContains([],nil) == false
    assert StructUtil.listContains(nil,nil) == false
    assert StructUtil.listContains([nil],nil) == true
    assert StructUtil.listContains(list,"") == true
    assert StructUtil.listContains(list," ") == false
    assert StructUtil.listContains(list,%{a: 1, b: 2}) == true
    assert StructUtil.listContains(list,%{a: 1, b: 5}) == false
  end
  
  test "[listContainsOne(list,values)]" do
    assert StructUtil.listContainsOne([],[]) == false
    assert StructUtil.listContainsOne([1,2,4,6],[5,7,8]) == false
    assert StructUtil.listContainsOne([1,2,4,6],[5,7,8,"A",%{a: 1, b: 3},9,6]) == true
    assert StructUtil.listContainsOne([1,2,4,6],[5,7,8,"A",%{a: 1, b: 3},9]) == false
    assert StructUtil.listContainsOne([1,2,4,6,%{a: 1, b: 3}],[5,7,8,"A",%{a: 1, b: 3},9]) == true
    assert StructUtil.listContainsOne([1,2,4,6,%{a: 1, b: 3}],[5,7,8,"A",%{a: 1, b: 5},9]) == false
  end
  
end