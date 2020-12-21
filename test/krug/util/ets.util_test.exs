defmodule Krug.EtsUtilTest do
  use ExUnit.Case
  
  doctest Krug.EtsUtil
  
  alias Krug.EtsUtil
  
  test "all functionalities" do
    assert EtsUtil.new(:echo) == :echo
    assert :ets.whereis(:echo) != :undefined
    assert EtsUtil.delete(:echo) == true
    assert :ets.whereis(:echo) == :undefined
    assert EtsUtil.new(:echo,"protected") == :echo
    assert :ets.whereis(:echo) != :undefined
    assert EtsUtil.delete(:echo) == true
    assert :ets.whereis(:echo) == :undefined
    assert EtsUtil.new(:echo,"private") == :echo
    assert :ets.whereis(:echo) != :undefined
    assert EtsUtil.delete(:echo) == true
    assert :ets.whereis(:echo) == :undefined
    assert EtsUtil.new(:echo,"public") == :echo
    assert :ets.whereis(:echo) != :undefined
    assert EtsUtil.delete(:echo) == true
    assert :ets.whereis(:echo) == :undefined
    assert EtsUtil.delete(:keyThatDontExists) == true
    assert EtsUtil.store_in_cache(:keyThatDontExists,"ping","pong") == false
    assert EtsUtil.new(:echo) == :echo
    assert :ets.whereis(:echo) != :undefined
    assert EtsUtil.store_in_cache(:echo,"ping","pong") == true
    assert EtsUtil.remove_from_cache(:keyThatDontExists,"ping") == true
    assert EtsUtil.remove_from_cache(:echo,"ping") == true
    assert EtsUtil.remove_from_cache(:echo,"foo") == true
    assert EtsUtil.remove_from_cache(:echo,"batatas") == true
    assert :ets.delete(:echo, "batatas") == true
    assert EtsUtil.delete(:echo) == true
    assert :ets.whereis(:echo) == :undefined
  end
  
  
end