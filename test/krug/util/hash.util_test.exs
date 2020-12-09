defmodule Krug.HashUtilTest do
  use ExUnit.Case
  
  doctest Krug.HashUtil
  
  alias Krug.HashUtil
  
  test "[cipher and compare]" do
    password = "123456"
    hash = HashUtil.hashPassword(password)
    hash2 = HashUtil.hashPassword(password)
    refute hash == hash2
    assert HashUtil.passwordMatch(hash,password)
    assert HashUtil.passwordMatch(hash2,password)
  end
  
  
end