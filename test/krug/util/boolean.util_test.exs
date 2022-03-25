defmodule Krug.BooleanUtilTest do
  use ExUnit.Case
  
  doctest Krug.BooleanUtil
  
  alias Krug.BooleanUtil
  
  test "[equals(boolean1,boolean2)]" do
    assert BooleanUtil.equals("true","true") == true
    assert BooleanUtil.equals("true",true) == true
    assert BooleanUtil.equals("true",1) == true
    assert BooleanUtil.equals("true","1") == true
    assert BooleanUtil.equals(true,true) == true
    assert BooleanUtil.equals(true,1) == true
    assert BooleanUtil.equals(true,"1") == true
    assert BooleanUtil.equals(1,1) == true
    assert BooleanUtil.equals(1,"1") == true
    assert BooleanUtil.equals("1","1") == true
    assert BooleanUtil.equals(true,"0") == false
    assert BooleanUtil.equals(true,0) == false
    assert BooleanUtil.equals(0,0) == true
    assert BooleanUtil.equals(true,"A") == false
	assert BooleanUtil.equals("A","A") == true
	assert BooleanUtil.equals("false","A") == true
	assert BooleanUtil.equals(false,"A") == true
	assert BooleanUtil.equals(0,"A") == true
	assert BooleanUtil.equals("0","A") == true
  end
  
  
end