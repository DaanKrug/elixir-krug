defmodule Krug.ArrayUtilTest do
  use ExUnit.Case
  
  doctest Krug.ArrayUtil
  
  alias Krug.ArrayUtil
  
  test "[rotate_right(array,positions)]" do
    assert ArrayUtil.rotate_right(nil,1) == nil
    assert ArrayUtil.rotate_right([],1) == []
    assert ArrayUtil.rotate_right([1],1) == [1]
    assert ArrayUtil.rotate_right([1],2) == [1]
    assert ArrayUtil.rotate_right([1,2,3,4],nil) == [1,2,3,4]
    assert ArrayUtil.rotate_right([1,2,3,4],0) == [1,2,3,4]
    assert ArrayUtil.rotate_right([1,2,3,4],1) == [2,3,4,1]
    assert ArrayUtil.rotate_right([1,2,3,4],2) == [3,4,1,2]
    assert ArrayUtil.rotate_right([1,2,3,4],3) == [4,1,2,3]
    assert ArrayUtil.rotate_right([1,2,3,4],4) == [1,2,3,4]
    assert ArrayUtil.rotate_right([1,2,3,4],5) == [2,3,4,1]
    assert ArrayUtil.rotate_right([1,2,3,4],6) == [3,4,1,2]
    assert ArrayUtil.rotate_right([1,2,3,4],7) == [4,1,2,3]
    assert ArrayUtil.rotate_right([1,2,3,4],7) == ArrayUtil.rotate_right([1,2,3,4],3)
  end
  
  
  test "[rotate_left(array,positions)]" do
    assert ArrayUtil.rotate_left(nil,1) == nil
    assert ArrayUtil.rotate_left([],1) == []
    assert ArrayUtil.rotate_left([1],1) == [1]
    assert ArrayUtil.rotate_left([1],2) == [1]
    assert ArrayUtil.rotate_left([1,2,3,4],nil) == [1,2,3,4]
    assert ArrayUtil.rotate_left([1,2,3,4],0) == [1,2,3,4]
    assert ArrayUtil.rotate_left([1,2,3,4],1) == [4,1,2,3]
    assert ArrayUtil.rotate_left([1,2,3,4],2) == [3,4,1,2]
    assert ArrayUtil.rotate_left([1,2,3,4],3) == [2,3,4,1]
    assert ArrayUtil.rotate_left([1,2,3,4],4) == [1,2,3,4]
    assert ArrayUtil.rotate_left([1,2,3,4],5) == [4,1,2,3]
    assert ArrayUtil.rotate_left([1,2,3,4],6) == [3,4,1,2]
    assert ArrayUtil.rotate_left([1,2,3,4],7) == [2,3,4,1]
    assert ArrayUtil.rotate_left([1,2,3,4],7) == ArrayUtil.rotate_left([1,2,3,4],3)
  end
  
  
end