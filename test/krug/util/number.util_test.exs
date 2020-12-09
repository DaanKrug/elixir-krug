defmodule Krug.NumberUtilTest do
  use ExUnit.Case
  
  doctest Krug.NumberUtil
  
  alias Krug.NumberUtil
  
  test "[maxInteger()]" do
    assert NumberUtil.maxInteger() == 4294967295
  end
  
  test "[isNan(number)]" do
    assert NumberUtil.isNan(10) == false
    assert NumberUtil.isNan(-10) == false
    assert NumberUtil.isNan("0") == false
    assert NumberUtil.isNan("-0") == false
    assert NumberUtil.isNan("0.0") == false
    assert NumberUtil.isNan("-0.0") == false
    assert NumberUtil.isNan("-10") == false
    assert NumberUtil.isNan("10") == false
    assert NumberUtil.isNan("-10") == false
    assert NumberUtil.isNan("10.5") == false
    assert NumberUtil.isNan("-10.5") == false
    assert NumberUtil.isNan("10,5") == false
    assert NumberUtil.isNan("-10,5") == false
    assert NumberUtil.isNan("10,5,5") == false
    assert NumberUtil.isNan("10.5.5") == false
    assert NumberUtil.isNan("10.5,5") == false
    assert NumberUtil.isNan("10,5.5") == false
    assert NumberUtil.isNan("-10,5,5") == false
    assert NumberUtil.isNan("-10.5.5") == false
    assert NumberUtil.isNan("-10.5,5") == false
    assert NumberUtil.isNan("-10,5.5") == false
    assert NumberUtil.isNan("-1-1") == true
    assert NumberUtil.isNan("1-1") == true
    assert NumberUtil.isNan("a") == true
    assert NumberUtil.isNan("1A") == true
    assert NumberUtil.isNan("1,A") == true
    assert NumberUtil.isNan("1.A") == true
    assert NumberUtil.isNan("1-A") == true
    assert NumberUtil.isNan("-1A") == true
    assert NumberUtil.isNan(".5") == true
    assert NumberUtil.isNan(".5.5") == true
    assert NumberUtil.isNan(".5,5") == true
    assert NumberUtil.isNan(",5.5") == true
    assert NumberUtil.isNan(",5,5") == true
    assert NumberUtil.isNan("-.5") == true
    assert NumberUtil.isNan("-.5.5") == true
    assert NumberUtil.isNan("-.5,5") == true
    assert NumberUtil.isNan("-,5.5") == true
    assert NumberUtil.isNan("-,5,5") == true
  end
  
  test "[toPositive(number)]" do
    assert NumberUtil.toPositive(-10) == 10.0
    assert NumberUtil.toPositive("-10") == 10.0
    assert NumberUtil.toPositive("-10,5") == 10.5
    assert NumberUtil.toPositive("-10.5") == 10.5
    assert NumberUtil.toPositive("-10.5A") == 0.0
    assert NumberUtil.toPositive("-1-0.5") == 0.0
    assert NumberUtil.toPositive("1-0.5") == 0.0
    assert NumberUtil.toPositive("1.0.5") == 10.5
    assert NumberUtil.toPositive("1,0,5") == 10.5
    assert NumberUtil.toPositive("1.0,5") == 10.5
    assert NumberUtil.toPositive("1,0.5") == 10.5
    assert NumberUtil.toPositive("-1.0.5") == 10.5
    assert NumberUtil.toPositive("-1,0,5") == 10.5
    assert NumberUtil.toPositive("-1.0,5") == 10.5
    assert NumberUtil.toPositive("-1,0.5") == 10.5
  end
  
  test "[toInteger(number)]" do
    assert NumberUtil.toInteger(nil) == 0
    assert NumberUtil.toInteger("") == 0
    assert NumberUtil.toInteger("1,,2") == 0
    assert NumberUtil.toInteger("1-2") == 0
    assert NumberUtil.toInteger("-1..2") == 0
    assert NumberUtil.toInteger("1A") == 0
    assert NumberUtil.toInteger(-1) == -1
    assert NumberUtil.toInteger(-1.2) == -1
    assert NumberUtil.toInteger("-1.2") == -1
    assert NumberUtil.toInteger("-1,2") == -1
    assert NumberUtil.toInteger(1) == 1
    assert NumberUtil.toInteger("1.2") == 1
    assert NumberUtil.toInteger("1,2") == 1
  end
  
  test "[toFloat(number)]" do
    assert NumberUtil.toFloat(nil) == 0.0
    assert NumberUtil.toFloat("") == 0.0
    assert NumberUtil.toFloat("1,,2") == 0.0
    assert NumberUtil.toFloat("1-2") == 0.0
    assert NumberUtil.toFloat("-1..2") == 0.0
    assert NumberUtil.toFloat("1A") == 0.0
    assert NumberUtil.toFloat(-1.2) == -1.2
    assert NumberUtil.toFloat("-1.2") == -1.2
    assert NumberUtil.toFloat("-1,2") == -1.2
    assert NumberUtil.toFloat("1.2") == 1.2
    assert NumberUtil.toFloat("1,2") == 1.2
    assert NumberUtil.toFloat("1.2,4") == 12.4
  	assert NumberUtil.toFloat("1,2,4") == 12.4
  	assert NumberUtil.toFloat("-1,2,4") == -12.4
  end
  
  test "[toFloatFormat(number,decimals,commaAsDecimalSeparator \\ true)]" do
    assert NumberUtil.toFloatFormat(nil,2) == "0,00"
    assert NumberUtil.toFloatFormat("",2) == "0,00"
    assert NumberUtil.toFloatFormat("1,,2",2) == "0,00"
    assert NumberUtil.toFloatFormat("1-2",2) == "0,00"
    assert NumberUtil.toFloatFormat("-1..2",2) == "0,00"
    assert NumberUtil.toFloatFormat("1A",2) == "0,00"
    assert NumberUtil.toFloatFormat(-1.2,2) == "-1,20"
    assert NumberUtil.toFloatFormat("-1.2",2) == "-1,20"
    assert NumberUtil.toFloatFormat("-1,2",2) == "-1,20"
    assert NumberUtil.toFloatFormat("1.2",2) == "1,20"
    assert NumberUtil.toFloatFormat("1,2",2) == "1,20"
    assert NumberUtil.toFloatFormat("1,2",5) == "1,20000"
    assert NumberUtil.toFloatFormat(nil,2,false) == "0.00"
    assert NumberUtil.toFloatFormat("",2,false) == "0.00"
    assert NumberUtil.toFloatFormat("1,,2",2,false) == "0.00"
    assert NumberUtil.toFloatFormat("1-2",2,false) == "0.00"
    assert NumberUtil.toFloatFormat("-1..2",2,false) == "0.00"
    assert NumberUtil.toFloatFormat("1A",2,false) == "0.00"
    assert NumberUtil.toFloatFormat(-1.2,2,false) == "-1.20"
    assert NumberUtil.toFloatFormat("-1.2",2,false) == "-1.20"
    assert NumberUtil.toFloatFormat("-1,2",2,false) == "-1.20"
    assert NumberUtil.toFloatFormat("1.2",2,false) == "1.20"
    assert NumberUtil.toFloatFormat("1,2",2,false) == "1.20"
    assert NumberUtil.toFloatFormat("1,2",5,false) == "1.20000"
  end
  
  test "[coalesce(value,valueIfEmptyOrNull,zeroAsEmpty \\ false)]" do
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
  
  test "[coalesceInterval(value,min,max)]" do
    assert NumberUtil.coalesceInterval(nil,10,20) == 0
    assert NumberUtil.coalesceInterval(nil,"10","20") == 0
    assert NumberUtil.coalesceInterval("",10,20) == 0
    assert NumberUtil.coalesceInterval(" ",10,20) == 0
    assert NumberUtil.coalesceInterval("1-1",10,20) == 0
    assert NumberUtil.coalesceInterval("1A",10,20) == 0
    assert NumberUtil.coalesceInterval(101,nil,20) == 101
    assert NumberUtil.coalesceInterval("101",nil,20) == 101
    assert NumberUtil.coalesceInterval("101","","20") == 101
    assert NumberUtil.coalesceInterval("101","10",nil) == 101
    assert NumberUtil.coalesceInterval("101"," ",20) == 101
    assert NumberUtil.coalesceInterval("101","-1-1",20) == 101
    assert NumberUtil.coalesceInterval("101","1A",20) == 101
    assert NumberUtil.coalesceInterval(101,10,20) == 20
    assert NumberUtil.coalesceInterval("101",10,20) == 20
    assert NumberUtil.coalesceInterval("5.5",10,20) == 10
    assert NumberUtil.coalesceInterval(15.5,10,20) == 15.5
    assert NumberUtil.coalesceInterval("15.5",10,20) == 15.5
  end
  
end





