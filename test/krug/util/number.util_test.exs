defmodule Krug.NumberUtilTest do
  use ExUnit.Case
  
  doctest Krug.NumberUtil
  
  alias Krug.NumberUtil
  
  test "[max_integer()]" do
    assert NumberUtil.max_integer() == 4294967295
  end
  
  test "[is_nan(number)]" do
    assert NumberUtil.is_nan(10) == false
    assert NumberUtil.is_nan(-10) == false
    assert NumberUtil.is_nan("0") == false
    assert NumberUtil.is_nan("-0") == false
    assert NumberUtil.is_nan("0.0") == false
    assert NumberUtil.is_nan("-0.0") == false
    assert NumberUtil.is_nan("-10") == false
    assert NumberUtil.is_nan("10") == false
    assert NumberUtil.is_nan("-10") == false
    assert NumberUtil.is_nan("10.5") == false
    assert NumberUtil.is_nan("-10.5") == false
    assert NumberUtil.is_nan("10,5") == false
    assert NumberUtil.is_nan("-10,5") == false
    assert NumberUtil.is_nan("10,5,5") == false
    assert NumberUtil.is_nan("10.5.5") == false
    assert NumberUtil.is_nan("10.5,5") == false
    assert NumberUtil.is_nan("10,5.5") == false
    assert NumberUtil.is_nan("-10,5,5") == false
    assert NumberUtil.is_nan("-10.5.5") == false
    assert NumberUtil.is_nan("-10.5,5") == false
    assert NumberUtil.is_nan("-10,5.5") == false
    assert NumberUtil.is_nan("-1-1") == true
    assert NumberUtil.is_nan("1-1") == true
    assert NumberUtil.is_nan("a") == true
    assert NumberUtil.is_nan("1A") == true
    assert NumberUtil.is_nan("1,A") == true
    assert NumberUtil.is_nan("1.A") == true
    assert NumberUtil.is_nan("1-A") == true
    assert NumberUtil.is_nan("-1A") == true
    assert NumberUtil.is_nan(".5") == true
    assert NumberUtil.is_nan(".5.5") == true
    assert NumberUtil.is_nan(".5,5") == true
    assert NumberUtil.is_nan(",5.5") == true
    assert NumberUtil.is_nan(",5,5") == true
    assert NumberUtil.is_nan("-.5") == true
    assert NumberUtil.is_nan("-.5.5") == true
    assert NumberUtil.is_nan("-.5,5") == true
    assert NumberUtil.is_nan("-,5.5") == true
    assert NumberUtil.is_nan("-,5,5") == true
  end
  
  test "[to_positive(number)]" do
    assert NumberUtil.to_positive(-10) == 10.0
    assert NumberUtil.to_positive("-10") == 10.0
    assert NumberUtil.to_positive("-10,5") == 10.5
    assert NumberUtil.to_positive("-10.5") == 10.5
    assert NumberUtil.to_positive("-10.5A") == 0.0
    assert NumberUtil.to_positive("-1-0.5") == 0.0
    assert NumberUtil.to_positive("1-0.5") == 0.0
    assert NumberUtil.to_positive("1.0.5") == 10.5
    assert NumberUtil.to_positive("1,0,5") == 10.5
    assert NumberUtil.to_positive("1.0,5") == 10.5
    assert NumberUtil.to_positive("1,0.5") == 10.5
    assert NumberUtil.to_positive("-1.0.5") == 10.5
    assert NumberUtil.to_positive("-1,0,5") == 10.5
    assert NumberUtil.to_positive("-1.0,5") == 10.5
    assert NumberUtil.to_positive("-1,0.5") == 10.5
  end
  
  test "[to_integer(number)]" do
    assert NumberUtil.to_integer(nil) == 0
    assert NumberUtil.to_integer("") == 0
    assert NumberUtil.to_integer("1,,2") == 0
    assert NumberUtil.to_integer("1-2") == 0
    assert NumberUtil.to_integer("-1..2") == 0
    assert NumberUtil.to_integer("1A") == 0
    assert NumberUtil.to_integer(-1) == -1
    assert NumberUtil.to_integer(-1.2) == -1
    assert NumberUtil.to_integer("-1.2") == -1
    assert NumberUtil.to_integer("-1,2") == -1
    assert NumberUtil.to_integer(1) == 1
    assert NumberUtil.to_integer("1.2") == 1
    assert NumberUtil.to_integer("1,2") == 1
  end
  
  test "[to_float(number)]" do
    assert NumberUtil.to_float(nil) == 0.0
    assert NumberUtil.to_float("") == 0.0
    assert NumberUtil.to_float("1,,2") == 0.0
    assert NumberUtil.to_float("1-2") == 0.0
    assert NumberUtil.to_float("-1..2") == 0.0
    assert NumberUtil.to_float("1A") == 0.0
    assert NumberUtil.to_float(-1.2) == -1.2
    assert NumberUtil.to_float("-1.2") == -1.2
    assert NumberUtil.to_float("-1,2") == -1.2
    assert NumberUtil.to_float("1.2") == 1.2
    assert NumberUtil.to_float("1,2") == 1.2
    assert NumberUtil.to_float("1.2,4") == 12.4
  	assert NumberUtil.to_float("1,2,4") == 12.4
  	assert NumberUtil.to_float("-1,2,4") == -12.4
  end
  
  test "[to_float_format(number,decimals,comma_as_decimal_separator \\ true)]" do
    assert NumberUtil.to_float_format(nil,2) == "0,00"
    assert NumberUtil.to_float_format("",2) == "0,00"
    assert NumberUtil.to_float_format("1,,2",2) == "0,00"
    assert NumberUtil.to_float_format("1-2",2) == "0,00"
    assert NumberUtil.to_float_format("-1..2",2) == "0,00"
    assert NumberUtil.to_float_format("1A",2) == "0,00"
    assert NumberUtil.to_float_format(-1.2,2) == "-1,20"
    assert NumberUtil.to_float_format("-1.2",2) == "-1,20"
    assert NumberUtil.to_float_format("-1,2",2) == "-1,20"
    assert NumberUtil.to_float_format("1.2",2) == "1,20"
    assert NumberUtil.to_float_format("1,2",2) == "1,20"
    assert NumberUtil.to_float_format("1,2",5) == "1,20000"
    assert NumberUtil.to_float_format(nil,2,false) == "0.00"
    assert NumberUtil.to_float_format("",2,false) == "0.00"
    assert NumberUtil.to_float_format("1,,2",2,false) == "0.00"
    assert NumberUtil.to_float_format("1-2",2,false) == "0.00"
    assert NumberUtil.to_float_format("-1..2",2,false) == "0.00"
    assert NumberUtil.to_float_format("1A",2,false) == "0.00"
    assert NumberUtil.to_float_format(-1.2,2,false) == "-1.20"
    assert NumberUtil.to_float_format("-1.2",2,false) == "-1.20"
    assert NumberUtil.to_float_format("-1,2",2,false) == "-1.20"
    assert NumberUtil.to_float_format("1.2",2,false) == "1.20"
    assert NumberUtil.to_float_format("1,2",2,false) == "1.20"
    assert NumberUtil.to_float_format("1,2",5,false) == "1.20000"
  end
  
  test "[coalesce(value,value_if_empty_or_nil,zero_as_empty \\ false)]" do
    assert NumberUtil.coalesce(nil,1,true) == 1
  	assert NumberUtil.coalesce(nil,1) == 1
  	assert NumberUtil.coalesce("",1) == 1
  	assert NumberUtil.coalesce(" ",1) == 1
  	assert NumberUtil.coalesce("1-1",1) == 1
  	assert NumberUtil.coalesce("1A",1) == 1
  	assert NumberUtil.coalesce(0,1) == 0
  	assert NumberUtil.coalesce(0,1,true) == 1
  	assert NumberUtil.coalesce(2,1) == 2
  	assert NumberUtil.coalesce("2",1) == 2
  	assert NumberUtil.coalesce("-1.2",2) == -1.2
  	assert NumberUtil.coalesce("-1,2",2) == -1.2
  	assert NumberUtil.coalesce("1.2,4",1) == 12.4
  	assert NumberUtil.coalesce("1,2,4",1) == 12.4
  	assert NumberUtil.coalesce("-1,2,4",1) == -12.4
  end
  
  test "[coalesce_interval(value,min,max)]" do
    assert NumberUtil.coalesce_interval(nil,10,20) == 0
    assert NumberUtil.coalesce_interval(nil,"10","20") == 0
    assert NumberUtil.coalesce_interval("",10,20) == 0
    assert NumberUtil.coalesce_interval(" ",10,20) == 0
    assert NumberUtil.coalesce_interval("1-1",10,20) == 0
    assert NumberUtil.coalesce_interval("1A",10,20) == 0
    assert NumberUtil.coalesce_interval(101,nil,20) == 101
    assert NumberUtil.coalesce_interval("101",nil,20) == 101
    assert NumberUtil.coalesce_interval("101","","20") == 101
    assert NumberUtil.coalesce_interval("101","10",nil) == 101
    assert NumberUtil.coalesce_interval("101"," ",20) == 101
    assert NumberUtil.coalesce_interval("101","-1-1",20) == 101
    assert NumberUtil.coalesce_interval("101","1A",20) == 101
    assert NumberUtil.coalesce_interval(101,10,20) == 20
    assert NumberUtil.coalesce_interval("101",10,20) == 20
    assert NumberUtil.coalesce_interval("5.5",10,20) == 10
    assert NumberUtil.coalesce_interval(15.5,10,20) == 15.5
    assert NumberUtil.coalesce_interval("15.5",10,20) == 15.5
  end
  
end





