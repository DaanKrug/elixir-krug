defmodule Krug.StringUtil do

  @moduledoc """
  Utilitary secure module to provide helpful methods to string manipulation,
  for general use.
  """

  alias Krug.NumberUtil


  
  @doc """
  Merge 2 strings, A and B using a ```join_string``` as a join connector.
  If A is nil a receive a empty string value, making the same process
  to B and to ```join_string```.
  
  If A and B are empty then return empty string.

  ## Examples

  ```elixir 
  iex > Krug.StringUtil.concat(nil,nil,nil)
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.concat(nil,nil,"-")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.concat("A",nil,"-")
  "A"
  ```
  ```elixir 
  iex > Krug.StringUtil.concat(nil,"B","-")
  "B"
  ```
  ```elixir 
  iex > Krug.StringUtil.concat("A","B","-")
  "A-B"
  ```
  ```elixir 
  iex > Krug.StringUtil.concat(" ","B","-")
  " -B"
  ```
  """
  def concat(string_a,string_b,join_string) do
    string_a = empty_if_nil(string_a)
    string_b = empty_if_nil(string_b)
    cond do
      (string_a == "") -> string_b
      (string_b == "") -> string_a
      true -> Enum.join([string_a,string_b],empty_if_nil(join_string))
    end
  end



  @doc """
  Convert a value to string, returning "" (empty string) if value is nil.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.empty_if_nil(nil)
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.empty_if_nil("")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.empty_if_nil(" ")
  " "
  ```
  ```elixir 
  iex > Krug.StringUtil.empty_if_nil("A")
  "A"
  ```
  ```elixir 
  iex > Krug.StringUtil.empty_if_nil(10)
  "10"
  ```
  ```elixir 
  iex > Krug.StringUtil.empty_if_nil(10.05)
  "10.05"
  ```
  ```elixir 
  iex > Krug.StringUtil.empty_if_nil(-10.05)
  "-10.05"
  ```
  """
  def empty_if_nil(target) do
    cond do
      (nil==target) -> ""
      true -> "#{target}"
    end
  end


  
  @doc """
  Receive a string ```target``` and split it to an array of strings.
  
  If ```target``` is nil return empty array. 
  
  If ```target``` is empty string return an array with empty string.
  
  If ```searched``` is nil/empty string or ```target``` don't contains ```searched```, 
  return an array with ```target``` string.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.split(nil,nil)
  []
  ```
  ```elixir 
  iex > Krug.StringUtil.split(nil,"")
  []
  ```
  ```elixir 
  iex > Krug.StringUtil.split("",nil)
  [""]
  ```
  ```elixir 
  iex > Krug.StringUtil.split("","")
  [""]
  ```
  ```elixir 
  iex > Krug.StringUtil.split("ABC",nil)
  ["ABC"]
  ```
  ```elixir 
  iex > Krug.StringUtil.split("ABC","")
  ["ABC"]
  ```
  ```elixir 
  iex > Krug.StringUtil.split("ABC","-")
  ["ABC"]
  ```
  ```elixir 
  iex > Krug.StringUtil.split("A-B-C","-")
  ["A","B","C"]
  ```
  ```elixir 
  iex > Krug.StringUtil.split(" A-B-C","-")
  [" A","B","C"]
  ```
  ```elixir 
  iex > Krug.StringUtil.split(" A-B-C ","-")
  [" A","B","C "]
  ```
  ```elixir 
  iex > Krug.StringUtil.split("-A-B-C-","-")
  ["","A","B","C",""]
  ```
  """
  def split(target,searched) do 
    cond do
      (nil == target) -> []
      (target == "") -> [""]
      (nil == searched or searched == "") -> ["#{target}"]
      (!(String.contains?("#{target}","#{searched}"))) -> ["#{target}"]
      true -> String.split("#{target}","#{searched}")
    end
  end


  
  @doc """
  Convert a value to string with all words capitalized.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.capitalize(nil)
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.capitalize("")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.capitalize(" ")
  " "
  ```
  ```elixir 
  iex > Krug.StringUtil.capitalize(" a e i ou ")
  " A E I Ou "
  ```
  ```elixir 
  iex > Krug.StringUtil.capitalize(" this is a method that capitalize ")
  " This Is A Method That Capitalize "
  ```
  """
  def capitalize(target) do
    target
      |> split(" ")
      |> Stream.map(&String.capitalize/1)
      |> Enum.join(" ")
  end



  @doc """
  Replace ```searched``` string value by ```replace_to``` string value, into 
  ```target``` string. Replaces recursively all occurences if is not present the
  recursion throwble. Otherwise replace one single time all occurencies without recursive calls 
  when recursion throwble is detected.
  
  Recursion throwble occur when ```searched``` is contained in ```replace_to```.
  Example: [searched = "123" and replace_to = "a x 123"] 
           or [searched = "123" and replace_to = " 123 "]
           or [searched = "123" and replace_to = "123"].
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.replace("aa   bb    cc","  "," ")
  "aa bb cc"
  ```
  ```elixir 
  iex > Krug.StringUtil.replace("aa       bb               cc","  "," ")
  "aa bb cc"
  ```
  ```elixir 
  iex > phrase = "replace all e letters by C letter"
  iex > Krug.StringUtil.replace(phrase,"e","c")
  "rcplacc all c lcttcrs by C lcttcr"
  ```
  ```elixir 
  iex > phrase = "replace non recursive because recursion throwble place"
  iex > Krug.StringUtil.replace(phrase,"ce","[Ace Ventures]")
  "repla[Ace Ventures] non recursive because recursion throwble pla[Ace Ventures]"
  ```
  """
  def replace(target,searched,replace_to) do 
    replace_to = empty_if_nil(replace_to)
    recursion_throwble = String.contains?(replace_to,"#{searched}")
    cond do
      (nil == target) -> nil
      (nil == searched or searched == "") -> "#{target}"
      (recursion_throwble and String.contains?("#{target}","#{searched}")) 
        -> String.replace("#{target}","#{searched}",replace_to)
      (String.contains?("#{target}","#{searched}")) 
        -> String.replace("#{target}","#{searched}",replace_to) |> replace(searched,replace_to)
      true -> "#{target}"
    end
  end
  
  
  
  @doc """
  Replaces all occurrences of each one element in ```searched_array```
  into ```target```, by ```replace_to``` string value.
  
  Uses recursively the ```replace(target,searched,replace_to)``` function,
  and because of this the rules for replacement are the same.
  
  If ```target``` is nil return nil.
  
  If ```target``` is empty string, or ```searched_array``` is nil/empty array return empty string.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.replace_all("afbfc   bfb    cfdc",["  ","f","c"],"0")
  "a0b000 b0b0000d0"
  ```
  ```elixir 
  iex > Krug.StringUtil.replace_all("aa       bb               cc",["  ","f","c"],"0")
  "aa000 bb0000000 00"
  ```
  ```elixir
  iex > phrase = "replace all e letters by C letter"
  iex > Krug.StringUtil.replace_all(phrase1,["e","a","p","t"],"c")
  "rcclccc cll c lccccrs by C lccccr"
  ```
  ```elixir
  iex > phrase = "replace non recursive because recursion throwble place"
  iex > Krug.StringUtil.replace_all(phrase,["ce","ur"],"[Ace Ventures]")
  "repla[Ace Vent[Ace Ventures]es] non rec[Ace Ventures]sive because rec[Ace Ventures]sion 
  throwble pla[Ace Vent[Ace Ventures]es]"
  ```
  """
  def replace_all(target,searched_array,replace_to) do 
    cond do
      (nil == target) -> nil
      (target == "" or nil == searched_array or length(searched_array) == 0) -> target
      true -> replace(target,hd(searched_array),replace_to) 
                |> replace_all(tl(searched_array),replace_to)
    end
  end
  
  
  
  @doc """
  Decodes a URI replacing the "+" codes to right " " chars, preserving 
  non URI "+" chars.
  
  ## Example

  ```elixir 
  iex > Krug.StringUtil.decode_uri("these ++ is ++ a ++ http://example.com/short+uri+example ++++")
  "these ++ is ++ a ++ http://example.com/short uri example +   "
  ```
  """
  def decode_uri(target) do
    mantain1 = " + "
    mantain2 = " +"
    mantain3 = "+ "
    mantain1_temp = "(((mantain1_temp)))"
    mantain2_temp = "(((mantain2_temp)))"
    mantain3_temp = "(((mantain3_temp)))"
  	target = URI.decode(target)
  	target = replace(target,mantain1,mantain1_temp)
  	target = replace(target,mantain2,mantain2_temp)
  	target = replace(target,mantain3,mantain3_temp)
  	target = replace(target,"+"," ")
  	target = replace(target,mantain1_temp,mantain1)
  	target = replace(target,mantain2_temp,mantain2)
  	replace(target,mantain3_temp,mantain3)
  end
  
  
  
  @doc """
  Extract a parameter value of an parameter values array.
  
  Useful in some situations, to handle parameters received from
  a api call for example.
  
  ## Examples

  ```elixir 
  iex > array_params = ["name=Johann Backend","age=54","address=404 street"]
  iex > Krug.StringUtil.get_decoded_value_param(array_params,"name","=")
  "Johann Backend"
  ```
  ```elixir 
  iex > array_params = ["name=Johann Backend","age=54","address=404 street"]
  iex > Krug.StringUtil.get_decoded_value_param(array_params,"address","=")
  "404 street"
  ```
  """
  def get_decoded_value_param(array_params,param,separator) do
    cond do
      (nil == array_params or length(array_params) == 0) -> ""
      (String.contains?(hd(array_params),"#{param}#{separator}")) 
        -> decode_uri(replace(hd(array_params),param <> separator,""))
      true -> get_decoded_value_param(tl(array_params),param,separator)
    end
  end
  
  
  
  @doc """
  Receives a value, force to string and completes the value 
  with left zeros until the ```value``` size == ```size``` parameter value
  received.
  
  Useful for visual formatting and bank services for example.
  
  If ```size``` is nil or <= 0, return the ```value``` received.
  
  If ```size``` is < that ```value``` received size, 
  return the ```value``` received truncated to ```size```.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.left_zeros(nil,5)
  "00000"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_zeros("",5)
  "00000"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_zeros(" ",5)
  "0000 "
  ```
  ```elixir 
  iex > Krug.StringUtil.left_zeros("A",5)
  "0000A"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_zeros("AB",5)
  "000AB"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_zeros(33,5)
  "00033"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_zeros(33.4,5)
  "033.4"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_zeros(33.45,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_zeros(33.456,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_zeros(33.4567,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_zeros(33.45678,5)
  "33.45"
  ```
  """
  def left_zeros(string,size) do
    string = empty_if_nil(string)
    cond do
      (nil == size or !(size > 0)) -> string
      (String.length(string) >= size) -> string |> String.slice(0..size - 1)
      true -> concat("0",string,"") |> left_zeros(size)
    end
  end
  
  
  
  @doc """
  Receives a value, force to string and completes the value 
  with right zeros until the ```value``` size == ```size``` parameter value
  received.
  
  Useful for visual formatting and bank services for example.
  
  If ```size``` is nil or <= 0, return the ```value``` received.
  
  If ```size``` is < that ```value``` received size, 
  return the ```value``` received truncated to ```size```.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.right_zeros(nil,5)
  "00000"
  ```
  ```elixir 
  iex > Krug.StringUtil.right_zeros("",5)
  "00000"
  ```
  ```elixir 
  iex > Krug.StringUtil.right_zeros(" ",5)
  " 0000"
  ```
  ```elixir 
  iex > Krug.StringUtil.right_zeros("A",5)
  "A0000"
  ```
  ```elixir 
  iex > Krug.StringUtil.right_zeros("AB",5)
  "AB000"
  ```
  ```elixir 
  iex > Krug.StringUtil.right_zeros(33,5)
  "33000"
  ```
  ```elixir 
  iex > Krug.StringUtil.right_zeros(33.4,5)
  "33.40"
  ```
  ```elixir 
  iex > Krug.StringUtil.right_zeros(33.45,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.right_zeros(33.456,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.right_zeros(33.4567,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.right_zeros(33.45678,5)
  "33.45"
  ```
  """
  def right_zeros(string,size) do
    string = empty_if_nil(string)
    cond do
      (nil == size or !(size > 0)) -> string
      (String.length(string) >= size) -> string |> String.slice(0..size - 1)
      true -> concat(string,"0","") |> right_zeros(size)
    end
  end
  
  
  
  @doc """
  Receives a value, force to string and completes the value 
  with left spaces until the ```value``` size == ```size``` parameter value
  received.
  
  Useful for visual formatting and bank services for example.
  
  If ```size``` is nil or <= 0, return the ```value``` received.
  
  If ```size``` is < that ```value``` received size, 
  return the ```value``` received truncated to ```size```.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.left_spaces(nil,5)
  "     "
  ```
  ```elixir 
  iex > Krug.StringUtil.left_spaces("",5)
  "     "
  ```
  ```elixir 
  iex > Krug.StringUtil.left_spaces(" ",5)
  "     "
  ```
  ```elixir 
  iex > Krug.StringUtil.left_spaces("A",5)
  "    A"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_spaces("AB",5)
  "   AB"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_spaces(33,5)
  "   33"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_spaces(33.4,5)
  " 33.4"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_spaces(33.45,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_spaces(33.456,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_spaces(33.4567,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.left_spaces(33.45678,5)
  "33.45"
  ```
  """
  def left_spaces(string,size) do
    string = empty_if_nil(string)
    cond do
      (nil == size or !(size > 0)) -> string
      (String.length(string) >= size) -> string |> String.slice(0..size - 1)
      true -> concat(" ",string,"") |> left_spaces(size)
    end
  end
  
  
  
  @doc """
  Receives a value, force to string and completes the value 
  with right spaces until the ```value``` size == ```size``` parameter value
  received.
  
  Useful for visual formatting and bank services for example.
  
  If ```size``` is nil or <= 0, return the ```value``` received.
  
  If ```size``` is < that ```value``` received size, 
  return the ```value``` received truncated to ```size```.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.right_spaces(nil,5)
  "     "
  ```
  ```elixir 
  iex > Krug.StringUtil.right_zeros("",5)
  "     "
  ```
  ```elixir 
  iex > Krug.StringUtil.right_spaces(" ",5)
  "     "
  ```
  ```elixir 
  iex > Krug.StringUtil.right_spaces("A",5)
  "A    "
  ```
  ```elixir 
  iex > Krug.StringUtil.right_spaces("AB",5)
  "AB   "
  ```
  ```elixir 
  iex > Krug.StringUtil.right_spaces(33,5)
  "33   "
  ```
  ```elixir 
  iex > Krug.StringUtil.right_spaces(33.4,5)
  "33.4 "
  ```
  ```elixir 
  iex > Krug.StringUtil.right_spaces(33.45,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.right_spaces(33.456,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.right_spaces(33.4567,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.right_spaces(33.45678,5)
  "33.45"
  ```
  """
  def right_spaces(string,size) do
    string = empty_if_nil(string)
    cond do
      (nil == size or !(size > 0)) -> string
      (String.length(string) >= size) -> string |> String.slice(0..size - 1)
      true -> right_spaces(concat(string," ",""),size)
    end
  end
  
  
  
  @doc """
  Convert a value to string, returning the value without left and right spaces.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.trim(nil)
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.trim("")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.trim(" ")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.trim(10.5)
  "10.5"
  ```
  ```elixir 
  iex > Krug.StringUtil.trim(" 10")
  "10"
  ```
  ```elixir 
  iex > Krug.StringUtil.trim(" 10.5 ")
  "10.5"
  ```
  """
  def trim(string) do
    empty_if_nil(string) |> String.trim()
  end
  
  
  
  @doc """
  Convert a value to string, and verify if this value contains one
  value present on received ```array``` of values. Each value on ```array``` of values
  is converted to string before realize the comparison. 
  
  If ```array``` is nil/empty return false.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.contains_one_element_of_array(nil,nil)
  false
  ```
  ```elixir 
  iex > Krug.StringUtil.contains_one_element_of_array("",nil)
  false
  ```
  ```elixir 
  iex > Krug.StringUtil.contains_one_element_of_array(" ",nil)
  false
  ```
  ```elixir 
  iex > Krug.StringUtil.contains_one_element_of_array("abcdef[]",[0,1,2,[]])
  false
  ```
  ```elixir 
  iex > Krug.StringUtil.contains_one_element_of_array("abcdef5",[0,1,2,[5,7]])
  false
  ```
  ```elixir 
  iex > Krug.StringUtil.contains_one_element_of_array("abcdef5,7",[0,1,2,[5,7]])
  false
  ```
  ```elixir 
  iex > Krug.StringUtil.contains_one_element_of_array("abcdef[5,7]",[0,1,2,[5,7]])
  false
  ```
  ```elixir 
  iex > Krug.StringUtil.contains_one_element_of_array("abcdef[]",[0,1,2,[],"]"])
  true
  ```
  ```elixir 
  iex > Krug.StringUtil.contains_one_element_of_array("abcdef[]",[0,1,2,[],"bc"])
  true
  ```
  ```elixir 
  iex > Krug.StringUtil.contains_one_element_of_array("abcdef[]",[0,1,2,[],"def["])
  true
  ```
  ```elixir 
  iex > Krug.StringUtil.contains_one_element_of_array("abcdef8[]",[0,1,2,[],8])
  true
  ```
  """
  def contains_one_element_of_array(target,array) do
    cond do
      (nil == array or length(array) == 0) -> false
      ("#{hd(array)}" == "") -> contains_one_element_of_array(target,tl(array))
      (String.contains?("#{target}","#{hd(array)}")) -> true
      true -> contains_one_element_of_array(target,tl(array))
    end
  end
  
  
  
  @doc """
  Convert a received value to a string. If this string is not empty return these value.
  Otherwise return the ```value_if_empty_or_nil``` parameter value.
  
  If ```value_if_empty_or_nil``` is nil return the received value or a empty string
  case the received value is nil.
  
  Useful to forces a default value, to validations for example. 
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.coalesce(nil,nil)
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.coalesce(nil,"")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.coalesce("",nil)
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.coalesce(" ",nil)
  " "
  ```
  ```elixir 
  iex > Krug.StringUtil.coalesce("A",nil)
  "A"
  ```
  ```elixir 
  iex > Krug.StringUtil.coalesce(nil,"A")
  "A"
  ```
  ```elixir 
  iex > Krug.StringUtil.coalesce("","A")
  "A"
  ```
  ```elixir 
  iex > Krug.StringUtil.coalesce(" ","A")
  "A"
  ```
  """
  def coalesce(value,value_if_empty_or_nil) do
    cond do
      (nil == value_if_empty_or_nil) -> empty_if_nil(value)
      (trim(value) == "") -> value_if_empty_or_nil
      true -> value
    end
  end
  
  
  
  @doc """
  Convert a numeric value ```char_code_string``` received to the
  correspondent character alfanumeric of any alphabet of
  any language.
  
  Useful in various functionalities that encode/decode chars.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.StringUtil.to_char("")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.StringUtil.to_char(" ")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.StringUtil.to_char("A")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.StringUtil.to_char("AB")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.StringUtil.to_char(5)
  "\x05"
  ```
  ```elixir 
  iex > Krug.StringUtil.StringUtil.to_char(65)
  "A"
  ```
  ```elixir 
  iex > Krug.StringUtil.StringUtil.to_char(225)
  "á"
  ```
  ```elixir 
  iex > Krug.StringUtil.StringUtil.to_char(16000)
  "㺀"
  ```
  """
  def to_char(char_code_string) do
    number = NumberUtil.to_integer(char_code_string)
    cond do
      (!(number > 0)) -> ""
      true -> List.to_string([number])
    end
  end
  
  
  
  @doc """
  Convert a string character value alfanumeric, of any alphabet of
  any language, contained in ```array``` received to the
  correspondent char code.
  
  Useful in various functionalities that encode/decode chars.
  
  If ```array``` is nil/empty or ```position``` > size of ```array```
  return nil.
  
  If element at ```position``` is empty/nil return nil.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.to_char_code(nil,0) 
  nil
  ```
  ```elixir 
  iex > Krug.StringUtil.to_char_code([],0) 
  nil
  ```
  ```elixir 
  iex > Krug.StringUtil.to_char_code([nil],0) 
  nil
  ```
  ```elixir 
  iex > Krug.StringUtil.to_char_code([""],0) 
  nil
  ```
  ```elixir 
  iex > Krug.StringUtil.to_char_code([""],3) 
  nil
  ```
  ```elixir 
  iex > Krug.StringUtil.to_char_code([" "],0)
  32
  ```
  ```elixir 
  iex > Krug.StringUtil.to_char_code(["\x05"],0)
  5
  ```
  ```elixir 
  iex > Krug.StringUtil.to_char_code(["A"],0)
  65
  ```
  ```elixir 
  iex > Krug.StringUtil.to_char_code(["á"],0)
  225
  ```
  ```elixir 
  iex > Krug.StringUtil.to_char_code(["㺀"],0)
  16000
  ```
  ```elixir 
  iex > Krug.StringUtil.to_char_code([nil,"",3,[],%{},"A"],5)
  65
  ```
  """
  def to_char_code(array,position) do
    cond do
      (nil == array or position >= length(array)) -> nil
      (Enum.member?(["",nil],array |> Enum.at(position))) -> nil
      true -> array |> Enum.at(position) |> to_char_code()
    end
  end
  
  
  
  defp to_char_code(string_char) do
    string_char 
      |> empty_if_nil() 
      |> String.to_charlist() 
      |> hd()
  end
  
  
    
end