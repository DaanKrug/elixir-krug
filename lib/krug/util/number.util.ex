defmodule Krug.NumberUtil do

  @moduledoc """
  Utilitary safe module for some numeric (non Math) operations/transformations.
  """
 
  alias Krug.StringUtil
  
  
  @numerals ["0","1","2","3","4","5","6","7","8","9"]
  @float_chars ["-",".",",","0","1","2","3","4","5","6","7","8","9"]
  @positive_float_chars [".",",","0","1","2","3","4","5","6","7","8","9"]
  @numeric_specials ["-",".",","]
  @numeric_specials_invalid ["-.","-,",".-",",-","--","..",".,",",.",",,"]
  
  
  
  @doc """
  Return the max integer value. 
  
  Useful for validations for database int(11) columns for example.

  ## Example

  ```elixir 
  iex > Krug.NumberUtil.max_integer()
  4294967295
  ```
  """
  def max_integer() do
    4294967295
  end
  
  
  
  @doc """
  Return if a value cannot be converted to a number. 

  ## Example

  ```elixir 
  iex > Krug.NumberUtil.is_nan(10)
  false
  ```
  ```elixir 
  iex > Krug.NumberUtil.is_nan("10")
  false
  ```
  ```elixir 
  iex > Krug.NumberUtil.is_nan("-1.0")
  false
  ```
  ```elixir 
  iex > Krug.NumberUtil.is_nan("-1,0")
  false
  ```
  ```elixir 
  iex > Krug.NumberUtil.is_nan("10A")
  true
  ```
  ```elixir 
  iex > Krug.NumberUtil.is_nan("-1-1")
  true
  ```
  ```elixir 
  iex > Krug.NumberUtil.is_nan("1-1")
  true
  ```
  ```elixir 
  iex > Krug.NumberUtil.is_nan(".5")
  true
  ```
  ```elixir 
  iex > Krug.NumberUtil.is_nan("-.5")
  true
  ```
  ```elixir 
  iex > Krug.NumberUtil.is_nan(",5")
  true
  ```
  ```elixir 
  iex > Krug.NumberUtil.is_nan("-,5")
  true
  ```
  """
  def is_nan(number) do
    cond do
      (is_number(number)) -> false 
      true -> is_nan2(number)
    end
  end
  
  
  
  @doc """
  Convert any number or string that could be converted in a number to
  a positive float number.
  
  If the ```number``` received its not a number/cannot be converted to one,
  then return ```0.0```.
  
  ## Examples

  ```elixir 
  iex > Krug.NumberUtil.to_positive(-10)
  10
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_positive("-10,5")
  10.5
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_positive("-10.5")
  10.5
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_positive("-10,5A")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_positive("-1-0,5")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_positive("1-0,5")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_positive("1.0.5")
  10.5
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_positive("1,0,5")
  10.5
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_positive("1.0,5")
  10.5
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_positive("1,0.5")
  10.5
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_positive("-1,0,5")
  10.5
  ```
  """
  def to_positive(number) do
    cond do
      (is_number(number)) -> number |> to_positive2()
      true -> number |> to_float() |> to_positive2()
    end
  end
  
  
  
  @doc """
  Return an integer value if a value received can be converted to a number.
  Otherwise return 0.

  ## Examples

  ```elixir 
  iex > Krug.NumberUtil.to_integer(nil)
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_integer("")
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_integer("1,,2")
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_integer("1-2")
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_integer("-1..2")
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_integer("1A")
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_integer(-1.2)
  -1
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_integer("-1.2")
  -1
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_integer("-1,2")
  -1
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_integer("1.2")
  1
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_integer("1,2")
  1
  ```
  """
  def to_integer(number) do
    cond do
      (is_integer(number)) -> number 
      (is_float(number)) -> number |> round()
      true -> number |> StringUtil.trim() |> to_integer2()
    end
  end
  
  
  
  @doc """
  Return a float value if a value received can be converted to a number.
  Otherwise return 0.

  ## Examples

  ```elixir 
  iex > Krug.NumberUtil.to_float(nil)
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float("")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float("1,,2")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float("1-2")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float("-1..2")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float("1A")
  0.0
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float(-1.2)
  -1.2
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float("-1.2")
  -1.2
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float("-1,2")
  -1.2
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float("1.2")
  1.2
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float("1,2")
  1.2
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float("1.2,4")
  12.4
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float("1,2,4")
  12.4
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float("-1,2.4")
  -12.4
  ```
  """
  def to_float(number) do
    cond do
      (is_float(number)) -> number
      (is_integer(number)) -> number
      (is_nan(number)) -> 0.0
      true -> convert_to_float(number)
    end
  end
  
  
  
  @doc """
  Applies ```to_float()``` to a received value, then format with
  ```decimals``` decimal digits, using ```,``` (default) or ```.```.

  ## Examples
  
  ```elixir 
  iex > Krug.NumberUtil.to_float_format(nil,2)
  0,00
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float_format("1A",2)
  0,00
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float_format("1,2",2)
  1,20
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float_format("1,2",5)
  1,20000
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float_format(nil,2,false)
  0.00
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float_format("1A",2,false)
  0.00
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float_format("1,2",2,false)
  1.20
  ```
  ```elixir 
  iex > Krug.NumberUtil.to_float_format("1,2",5,false)
  1.20000
  ```
  """
  def to_float_format(number,decimals,comma_as_decimal_separator \\ true) do
    number = number |> to_float()
    number_array = :io_lib.format("~.#{decimals}f",[number]) |> StringUtil.split(".")
    cond do
      (nil == decimals or !(decimals > 0)) -> number_array |> hd()
      true -> to_float_format2(number_array,decimals,comma_as_decimal_separator)
    end
  end
  
  
  
  @doc """
  Verify if a value received is a valid number. If is valid return the
  value received passing by ```to_integer()``` or ```toFloat```. 
  Otherwise return the ```value_if_empty_or_nil``` parameter value.
  
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
  def coalesce(value,value_if_empty_or_nil,zero_as_empty \\ false) do
    value = value |> StringUtil.trim()
    cond do
      (value == "") -> value_if_empty_or_nil
      (value |> is_nan3()) -> value_if_empty_or_nil
      true -> coalesce2(value,value_if_empty_or_nil,zero_as_empty)
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
  iex > Krug.NumberUtil.coalesce_interval(nil,"10","20")
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce_interval("",10,"20")
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce_interval("1-1",10,20)
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce_interval("1A",10,20)
  0
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce_interval("101","10",nil)
  101
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce_interval("101","1A",20)
  101
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce_interval(101,10,20)
  20
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce_interval("5.5","10",20)
  10
  ```
  ```elixir 
  iex > Krug.NumberUtil.coalesce_interval("15.5",10,20)
  15.5
  ```
  """
  def coalesce_interval(value,min,max) do
    cond do
      (is_nan(value)) -> 0
      (is_nan(min) or is_nan(max)) -> numberize(value)
      true -> coalesce_interval2(value,min,max)
    end
  end
  
  
  
  defp coalesce_interval2(value,min,max) do
    value2 = numberize(value)
    min2 = numberize(min)
    max2 = numberize(max)
    cond do
      (value2 < min2) -> min2
      (value2 > max2) -> max2
      true -> value2
    end
  end
  
  
  
  defp numberize(value) do
    cond do
      (is_number(value)) -> value
      true -> numberize2(value)
    end
  end
  
  
  
  defp numberize2(value) do
    value2 = value |> StringUtil.replace(",",".",true)
    cond do
      (String.contains?(value2,".")) -> to_float(value2)
      true -> to_integer(value2)
    end
  end
  
  
  
  defp convert_to_float(number) do
    number = StringUtil.replace(number," ","",true) |> StringUtil.replace(",",".",true)
    cond do
      (!(String.contains?(number,"."))) -> number |> String.to_integer()
      true -> handle_extra_float_dots(number) |> String.to_float()
    end
  end
  
  
  
  defp handle_extra_float_dots(number) do
    reversed_array = StringUtil.split(number,".") |> Enum.reverse()
    double_part = hd(reversed_array)
    integer_part = tl(reversed_array) |> Enum.reverse() |> IO.iodata_to_binary()
    [integer_part,".",double_part] |> IO.iodata_to_binary()
  end
  
  
  
  @doc false
  defp is_nan2(number) do
    number = number |> StringUtil.trim()
    cond do
      (number == "") -> true
      true -> is_nan3(number)
    end
  end
  
  
  
  @doc false
  defp is_nan3(number) do
    cond do
      (StringUtil.replace_all(number,@float_chars,"") != "") -> true
      (Enum.member?([".",","],number |> StringUtil.slice(0,0))) -> true
      (StringUtil.replace_all(number,@numeric_specials,"") == "") -> true
      (StringUtil.contains_one_element_of_array(number,@numeric_specials_invalid)) -> true
      true -> is_nan4(number)
    end
  end
  
  
  
  @doc false
  defp is_nan4(number) do
    size = String.length(number)
    number2 = cond do 
      (size > 1) -> number |> StringUtil.slice(1,size)
      true -> number
    end
    StringUtil.replace_all(number2,@positive_float_chars,"") != ""
  end
  
  
  
  @doc false
  defp to_positive2(number) do
    cond do
      (number < 0) -> (number * -1)
      true -> number
    end
  end
  
  
  
  @doc false
  defp to_integer2(number) do
    cond do
      (number == "") -> 0
      (number |> StringUtil.replace_all(@numerals,"") == "")
        -> number |> String.to_integer()
      (number |> is_nan3()) -> 0
      true -> number 
                |> StringUtil.replace(",",".",true) 
                |> StringUtil.split(".")
                |> hd()
                |> String.to_integer()
    end
  end


  
  @doc false
  defp to_float_format2(number_array,decimals,comma_as_decimal_separator) do
    decimal_part = cond do
      (length(number_array) > 1) -> number_array |> tl() |> hd() |> StringUtil.right_zeros(decimals)
      true -> "" |> StringUtil.right_zeros(decimals)
    end
    integer_part = number_array |> hd()
    cond do
      (!comma_as_decimal_separator) -> [integer_part,".",decimal_part] |> IO.iodata_to_binary()
      true -> [integer_part,",",decimal_part] |> IO.iodata_to_binary()
    end
  end


  
  @doc false
  defp coalesce2(value,value_if_empty_or_nil,zero_as_empty) do
    value = value |> StringUtil.replace(",",".",true)
    cond do
      (String.contains?(value,".")) -> coalesce_float(value,value_if_empty_or_nil,zero_as_empty)
      true -> coalesce_integer(value,value_if_empty_or_nil,zero_as_empty)
    end
  end
  
  
  
  @doc false
  defp coalesce_integer(value,value_if_empty_or_nil,zero_as_empty) do
    value = to_integer(value)
    cond do
      (zero_as_empty and value == 0) 
        -> value_if_empty_or_nil
      true -> value
    end
  end
  
  
  
  @doc false
  defp coalesce_float(value,value_if_empty_or_nil,zero_as_empty) do
    value = to_float(value)
    cond do
      (zero_as_empty and value == 0.0) 
        -> value_if_empty_or_nil
      true -> value
    end
  end
  
  
  
end
