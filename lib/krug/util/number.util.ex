defmodule Krug.NumberUtil do

  @moduledoc """
  Utilitary safe module for some numeric (non Math) operations/transformations.
  """
 
  alias Krug.StringUtil
  
  
  
  @doc """
  Return the max integer value. 
  
  Useful for validations for database int(11) columns for example.

  ## Example

  ```elixir 
  iex > Krug.NumberUtil.maxInteger()
  4294967295
  ```
  """
  def maxInteger() do
    4294967295
  end
  
  
  
  @doc """
  Return if a value cannot be converted to a number. 

  ## Example

  ```elixir 
  iex > Krug.NumberUtil.isNan(10)
  false
  ```
  ```elixir 
  iex > Krug.NumberUtil.isNan("10")
  false
  ```
  ```elixir 
  iex > Krug.NumberUtil.isNan("-1.0")
  false
  ```
  ```elixir 
  iex > Krug.NumberUtil.isNan("-1,0")
  false
  ```
  ```elixir 
  iex > Krug.NumberUtil.isNan("10A")
  true
  ```
  ```elixir 
  iex > Krug.NumberUtil.isNan("-1-1")
  true
  ```
  ```elixir 
  iex > Krug.NumberUtil.isNan("1-1")
  true
  ```
  ```elixir 
  iex > Krug.NumberUtil.isNan(".5")
  true
  ```
  ```elixir 
  iex > Krug.NumberUtil.isNan("-.5")
  true
  ```
  ```elixir 
  iex > Krug.NumberUtil.isNan(",5")
  true
  ```
  ```elixir 
  iex > Krug.NumberUtil.isNan("-,5")
  true
  ```
  """
  def isNan(number) do
    number = number |> StringUtil.trim() 
    number2 = number
    size = String.length(number2)
    number2 = cond do 
      (size > 1) -> number2 |> String.slice(1..size)
      true -> number2
    end
    invalidCombinations = ["-.","-,",".-",",-","--","..",".,",",.",",,"]
    cond do
      (number == "" || number2 == "") -> true 
      (Enum.member?([".",","],number |> String.slice(0..0))) -> true
      (StringUtil.replaceAll(number,["-",".",","],"") == "") -> true
      (StringUtil.containsOneElementOfArray(number,invalidCombinations)) -> true
      (StringUtil.replaceAll(number,numberChars(false),"") != "") -> true
      (StringUtil.replaceAll(number2,numberChars(true),"") != "") -> true 
      true -> false
    end
  end
  
  
  
  @doc """
  Convert any number or string that could be converted in a number to
  a positive float number.
  
  If the ```number``` received its not a number/cannot be converted to one,
  then return ```0.0```.
  
  ## Examples

  ```elixir 
  iex > Krug.NumberUtil.toPositive(-10)
  10
  ```
  ```elixir 
  iex > Krug.NumberUtil.toPositive("-10,5")
  10.5
  ```
  ```elixir 
  iex > Krug.NumberUtil.toPositive("-10.5")
  10.5
  ```
  ```elixir 
  iex > Krug.NumberUtil.toPositive("-10,5A")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toPositive("-1-0,5")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toPositive("1-0,5")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toPositive("1.0.5")
  10.5
  ```
  ```elixir 
  iex > Krug.NumberUtil.toPositive("1,0,5")
  10.5
  ```
  ```elixir 
  iex > Krug.NumberUtil.toPositive("1.0,5")
  10.5
  ```
  ```elixir 
  iex > Krug.NumberUtil.toPositive("1,0.5")
  10.5
  ```
  ```elixir 
  iex > Krug.NumberUtil.toPositive("-1,0,5")
  10.5
  ```
  """
  def toPositive(number) do
    number = toFloat(number)
    cond do
      (number < 0) -> (number * -1)
      true -> number
    end
  end
  
  
  
  @doc """
  Return an integer value if a value received can be converted to a number.
  Otherwise return 0.

  ## Examples

  ```elixir 
  iex > Krug.NumberUtil.toInteger(nil)
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toInteger("")
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toInteger("1,,2")
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toInteger("1-2")
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toInteger("-1..2")
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toInteger("1A")
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toInteger(-1.2)
  -1
  ```
  ```elixir 
  iex > Krug.NumberUtil.toInteger("-1.2")
  -1
  ```
  ```elixir 
  iex > Krug.NumberUtil.toInteger("-1,2")
  -1
  ```
  ```elixir 
  iex > Krug.NumberUtil.toInteger("1.2")
  1
  ```
  ```elixir 
  iex > Krug.NumberUtil.toInteger("1,2")
  1
  ```
  """
  def toInteger(number) do
    cond do
      (isNan(number)) -> 0
      true -> "#{number}" |> StringUtil.replace(",",".") 
                          |> StringUtil.split(".")
                          |> Enum.at(0) 
                          |> String.to_integer()
    end
  end
  
  
  
  @doc """
  Return a float value if a value received can be converted to a number.
  Otherwise return 0.

  ## Examples

  ```elixir 
  iex > Krug.NumberUtil.toFloat(nil)
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloat("")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloat("1,,2")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloat("1-2")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloat("-1..2")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloat("1A")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloat(-1.2)
  -1.2
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloat("-1.2")
  -1.2
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloat("-1,2")
  -1.2
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloat("1.2")
  1.2
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloat("1,2")
  1.2
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloat("1.2,4")
  12.4
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloat("1,2,4")
  12.4
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloat("-1,2.4")
  -12.4
  ```
  """
  def toFloat(number) do
    cond do
      (isNan(number)) -> 0.0
      true -> converToFloat(number)
    end
  end
  
  
  
  @doc """
  Applies ```toFloat()``` to a received value, then format whit
  ```decimals``` decimal digits, using ```,``` (default) or ```.```.

  ## Examples
  
  ```elixir 
  iex > Krug.NumberUtil.toFloatFormat(nil,2)
  0,00
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloatFormat("1A",2)
  0,00
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloatFormat("1,2",2)
  1,20
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloatFormat("1,2",5)
  1,20000
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloatFormat(nil,2,false)
  0.00
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloatFormat("1A",2,false)
  0.00
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloatFormat("1,2",2,false)
  1.20
  ```
  ```elixir 
  iex > Krug.NumberUtil.toFloatFormat("1,2",5,false)
  1.20000
  ```
  """
  def toFloatFormat(number,decimals,commaAsDecimalSeparator \\ true) do
    number = number |> toFloat()
    arr = :io_lib.format("~.#{decimals}f",[number]) |> StringUtil.split(".")
    dec = cond do
      (nil == decimals or !(decimals > 0)) -> ""
      (length(arr) > 1) -> Enum.at(arr,1) |> StringUtil.rightZeros(decimals)
      true -> "" |> StringUtil.rightZeros(decimals)
    end
    cond do
      (nil == decimals or !(decimals > 0)) -> "#{Enum.at(arr,0)}"
      (!commaAsDecimalSeparator) -> "#{Enum.at(arr,0)}.#{dec}"
      true -> "#{Enum.at(arr,0)},#{dec}"
    end
  end
  
  
  
  @doc """
  Verify if a value received is a valid number. If is valid return the
  value received passing by ```toInteger()``` or ```toFloat```. 
  Otherwise return the ```valueIfEmptyOrNull``` parameter value.
  
  Useful to forces a default value, to validations for example. 
  
  ## Examples
 
  ```elixir 
  iex > Krug.NumberUtil.coalesce(nil,1)
  1
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce("",1)
  1
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce(" ",1)
  1
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce("1-1",1)
  1
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce("1A",1)
  1
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce(0,1)
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce(0,1,true)
  1
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce("0",1,true)
  1
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce(2,1)
  2
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce("2",1)
  2
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce("1.2,4",1)
  12.4
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce("1,2,4",1)
  12.4
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce("-1,2.4",1)
  -12.4
  ```
  """
  def coalesce(value,valueIfEmptyOrNull,zeroAsEmpty \\ false) do
    value = value |> StringUtil.replace(",",".")
    valueIfEmptyOrNull = valueIfEmptyOrNull |> StringUtil.replace(",",".")
    cond do
      (zeroAsEmpty and String.contains?(value,".") and toFloat(value) == 0.0) 
        -> toFloat(valueIfEmptyOrNull)
      (zeroAsEmpty and !String.contains?(value,".") and toInteger(value) == 0) 
        -> toInteger(valueIfEmptyOrNull)
      (!isNan(value) and String.contains?(value,".")) 
        -> toFloat(value)
      (!isNan(value)) 
        -> toInteger(value)
      (!isNan(valueIfEmptyOrNull) and String.contains?(valueIfEmptyOrNull,".")) 
        -> toFloat(valueIfEmptyOrNull)
      (!isNan(valueIfEmptyOrNull)) 
        -> toInteger(valueIfEmptyOrNull)
      true -> 0
    end
  end
  
  
  
  @doc """
  Verify if a value received is a valid number and is >= min
  and <= max.
  
  If the value received not is a valid number return 0.
  
  If the ```min``` or ```max``` parameter value not is a valid number return the value received.
  
  If value < min return min.
  
  If value > max return max.

  ## Examples
  
  ```elixir 
  iex > Krug.NumberUtil.coalesceInterval(nil,"10","20")
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesceInterval("",10,"20")
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesceInterval("1-1",10,20)
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesceInterval("1A",10,20)
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesceInterval("101","10",nil)
  101
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesceInterval("101","1A",20)
  101
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesceInterval(101,10,20)
  20
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesceInterval("5.5","10",20)
  10
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesceInterval("15.5",10,20)
  15.5
  ```
  """
  def coalesceInterval(value,min,max) do
    value2 = numberize(value)
    min2 = numberize(min)
    max2 = numberize(max)
    cond do
      (isNan(value)) -> 0
      (isNan(min) or isNan(max)) -> value2
      (value2 < min2) -> min2
      (value2 > max2) -> max2
      true -> value2
    end
  end
  
  
  
  defp numberize(value) do
    value2 = value |> StringUtil.replace(",",".")
    cond do
      (isNan(value)) -> 0 
      (String.contains?(value2,".")) -> toFloat(value2)
      true -> toInteger(value2)
    end
  end
  
  
  
  defp numberChars(onlyPositive) do
    cond do
      (onlyPositive) -> [",",".","0","1","2","3","4","5","6","7","8","9"]
      true -> ["-",",",".","0","1","2","3","4","5","6","7","8","9"]
    end
  end
  
  
  
  defp converToFloat(number) do
    number = StringUtil.replace(number," ","") |> StringUtil.replace(",",".")
    cond do
      (!(String.contains?(number,"."))) -> number |> String.to_integer()
      true -> handleExtraFloatDots(number) |> String.to_float()
    end
  end
  
  
  
  defp handleExtraFloatDots(number) do
    reverseArray = StringUtil.split(number,".") |> Enum.reverse()
    doublePart = hd(reverseArray)
    integerPart = tl(reverseArray) |> Enum.reverse() |> Enum.join("")
    [integerPart,doublePart] |> Enum.join(".")
  end
  
  
  
end
