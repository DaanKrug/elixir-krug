defmodule Krug.HashUtilTest do
  use ExUnit.Case
  
  doctest Krug.HashUtil
  
  alias Krug.HashUtil
  
  test "[cipher and compare]" do
    password = "123456"
    hash = HashUtil.hash_password(password)
    hash2 = HashUtil.hash_password(password)
    refute hash == hash2
    assert HashUtil.password_match(hash,password)
    assert HashUtil.password_match(hash2,password)
  end
  
  
end