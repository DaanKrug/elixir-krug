defmodule Krug.StructUtilTest do
  use ExUnit.Case
  
  doctest Krug.StructUtil
  
  alias Krug.StructUtil
  
  test "[get_value_from_tuple(tuple)]" do
    assert StructUtil.get_value_from_tuple({:ok}) == nil
    assert StructUtil.get_value_from_tuple({:ok,nil}) == nil
    assert StructUtil.get_value_from_tuple({:ok,[]}) == []
    assert StructUtil.get_value_from_tuple({:ok,%{}}) == %{}
    assert StructUtil.get_value_from_tuple({:ok, [1,2,3]}) == [1,2,3]
    assert StructUtil.get_value_from_tuple({:ok, %{a: 1, b: 2, c: 3}}) == %{a: 1, b: 2, c: 3}
    assert StructUtil.get_value_from_tuple({:error, %{a: 1, b: 2, c: 3}}) == %{a: 1, b: 2, c: 3}
    assert StructUtil.get_value_from_tuple({:error, "Error Message"}) == "Error Message"
  end
  
  test "[list_contains(list,value)]" do
    list = [1,%{a: 1, b: 2},"",nil,[1,2,3],5]
    assert StructUtil.list_contains([],nil) == false
    assert StructUtil.list_contains(nil,nil) == false
    assert StructUtil.list_contains([nil],nil) == true
    assert StructUtil.list_contains(list,"") == true
    assert StructUtil.list_contains(list," ") == false
    assert StructUtil.list_contains(list,%{a: 1, b: 2}) == true
    assert StructUtil.list_contains(list,%{a: 1, b: 5}) == false
  end
  
  test "[list_contains_one_of(list,values)]" do
    assert StructUtil.list_contains_one_of([],[]) == false
    assert StructUtil.list_contains_one_of([1,2,4,6],[5,7,8]) == false
    assert StructUtil.list_contains_one_of([1,2,4,6],[5,7,8,"A",%{a: 1, b: 3},9,6]) == true
    assert StructUtil.list_contains_one_of([1,2,4,6],[5,7,8,"A",%{a: 1, b: 3},9]) == false
    assert StructUtil.list_contains_one_of([1,2,4,6,%{a: 1, b: 3}],[5,7,8,"A",%{a: 1, b: 3},9]) == true
    assert StructUtil.list_contains_one_of([1,2,4,6,%{a: 1, b: 3}],[5,7,8,"A",%{a: 1, b: 5},9]) == false
  end
  
  test "[get_key_par_value_from_list(key,list)]" do
    list = ["name=Johannes Backend","email=johannes@has.not.email"]
    list2 = [" name=Johannes Backend","email =johannes@has.not.email"]
    list3 = [" name = Johannes Backend "," email = johannes@has.not.email "]
    assert StructUtil.get_key_par_value_from_list(nil,nil) == nil
    assert StructUtil.get_key_par_value_from_list(nil,[]) == nil
    assert StructUtil.get_key_par_value_from_list(nil,[nil]) == nil
    assert StructUtil.get_key_par_value_from_list(nil,[""]) == nil
    assert StructUtil.get_key_par_value_from_list("",nil) == nil
    assert StructUtil.get_key_par_value_from_list("",[]) == nil
    assert StructUtil.get_key_par_value_from_list("",[nil]) == nil
    assert StructUtil.get_key_par_value_from_list("",[""]) == nil
    assert StructUtil.get_key_par_value_from_list(" ",nil) == nil
    assert StructUtil.get_key_par_value_from_list(" ",[]) == nil
    assert StructUtil.get_key_par_value_from_list(" ",[nil]) == nil
    assert StructUtil.get_key_par_value_from_list(" ",[""]) == nil
    assert StructUtil.get_key_par_value_from_list("name",nil) == nil
    assert StructUtil.get_key_par_value_from_list("name",[]) == nil
    assert StructUtil.get_key_par_value_from_list("name",[nil]) == nil
    assert StructUtil.get_key_par_value_from_list("name",[""]) == nil
    assert StructUtil.get_key_par_value_from_list("keyThatNotExists",list) == nil
    assert StructUtil.get_key_par_value_from_list("name",list) == "Johannes Backend"
    assert StructUtil.get_key_par_value_from_list("email",list) == "johannes@has.not.email"
    assert StructUtil.get_key_par_value_from_list("name",list2) == "Johannes Backend"
    assert StructUtil.get_key_par_value_from_list("email",list2) == "johannes@has.not.email"
    assert StructUtil.get_key_par_value_from_list("name",list3) == "Johannes Backend"
    assert StructUtil.get_key_par_value_from_list("email",list3) == "johannes@has.not.email"
  end
  
end