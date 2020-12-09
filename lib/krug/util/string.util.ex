defmodule Krug.StringUtil do

  @moduledoc """
  Utilitary secure module to provide helpful methods to string manipulation,
  for general use.
  """

  alias Krug.NumberUtil


  
  @doc """
  Merge 2 strings, A and B using a ```joinString``` as a join connector.
  If A is nil a receive a empty string value, making the same process
  to B and to ```joinString```.
  
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
  def concat(stringA,stringB,joinString) do
    stringA = emptyIfNil(stringA)
    stringB = emptyIfNil(stringB)
    cond do
      (stringA == "") -> stringB
      (stringB == "") -> stringA
      true -> Enum.join([stringA,stringB],emptyIfNil(joinString))
    end
  end



  @doc """
  Convert a value to string, returning "" (empty string) if value is nil.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.emptyIfNil(nil)
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.emptyIfNil("")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.emptyIfNil(" ")
  " "
  ```
  ```elixir 
  iex > Krug.StringUtil.emptyIfNil("A")
  "A"
  ```
  ```elixir 
  iex > Krug.StringUtil.emptyIfNil(10)
  "10"
  ```
  ```elixir 
  iex > Krug.StringUtil.emptyIfNil(10.05)
  "10.05"
  ```
  ```elixir 
  iex > Krug.StringUtil.emptyIfNil(-10.05)
  "-10.05"
  ```
  """
  def emptyIfNil(target) do
    cond do
      (nil==target) -> ""
      true -> "#{target}"
    end
  end


  
  @doc """
  Receive a string ```target``` and split it to an array of strings.
  
  If ```target``` is nil return empty array. 
  
  If ```target``` is empty string return an array whit empty string.
  
  If ```searched``` is nil/empty string or ```target``` don't contains ```searched```, 
  return an array whit ```target``` string.
  
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
  Convert a value to string whit all words capitalized.
  
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
  Replace ```searched``` string value by ```replaceTo``` string value, into 
  ```target``` string. Replaces recursively all occurences if is not present the
  recursion throwble. Otherwise replace one single time all occurencies whitout recursive calls 
  when recursion throwble is detected.
  
  Recursion throwble occur when ```searched``` is contained in ```replaceTo```.
  Example: [searched = "123" and replaceTo = "a x 123"] 
           or [searched = "123" and replaceTo = " 123 "]
           or [searched = "123" and replaceTo = "123"].
  
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
  def replace(target,searched,replaceTo) do 
    replaceTo = emptyIfNil(replaceTo)
    recursionThrowble = String.contains?(replaceTo,"#{searched}")
    cond do
      (nil == target) -> nil
      (nil == searched or searched == "") -> "#{target}"
      (recursionThrowble and String.contains?("#{target}","#{searched}")) 
        -> String.replace("#{target}","#{searched}",replaceTo)
      (String.contains?("#{target}","#{searched}")) 
        -> String.replace("#{target}","#{searched}",replaceTo) |> replace(searched,replaceTo)
      true -> "#{target}"
    end
  end
  
  
  
  @doc """
  Replaces all occurrences of each one element in ```searchedArray```
  into ```target```, by ```replaceTo``` string value.
  
  Uses recursively the ```replace(target,searched,replaceTo)``` function,
  because this the rules for replacement are the same.
  
  If ```target``` is nil return nil.
  
  If ```target``` is empty string, or ```searchedArray``` is nil/empty array return empty string.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.replaceAll("afbfc   bfb    cfdc",["  ","f","c"],"0")
  "a0b000 b0b0000d0"
  ```
  ```elixir 
  iex > Krug.StringUtil.replaceAll("aa       bb               cc",["  ","f","c"],"0")
  "aa000 bb0000000 00"
  ```
  ```elixir
  iex > phrase = "replace all e letters by C letter"
  iex > Krug.StringUtil.replaceAll(phrase1,["e","a","p","t"],"c")
  "rcclccc cll c lccccrs by C lccccr"
  ```
  ```elixir
  iex > phrase = "replace non recursive because recursion throwble place"
  iex > Krug.StringUtil.replaceAll(phrase,["ce","ur"],"[Ace Ventures]")
  "repla[Ace Vent[Ace Ventures]es] non rec[Ace Ventures]sive because rec[Ace Ventures]sion 
  throwble pla[Ace Vent[Ace Ventures]es]"
  ```
  """
  def replaceAll(target,searchedArray,replaceTo) do 
    cond do
      (nil == target) -> nil
      (target == "" or nil == searchedArray or length(searchedArray) == 0) -> target
      true -> replace(target,hd(searchedArray),replaceTo) 
                |> replaceAll(tl(searchedArray),replaceTo)
    end
  end
  
  
  
  @doc """
  Decodes a URI replacing the "+" codes to right " " chars, preserving 
  non URI "+" chars.
  
  ## Example

  ```elixir 
  iex > Krug.StringUtil.decodeUri("these ++ is ++ a ++ http://example.com/short+uri+example ++++")
  "these ++ is ++ a ++ http://example.com/short uri example +   "
  ```
  """
  def decodeUri(target) do
    mantain1 = " + "
    mantain2 = " +"
    mantain3 = "+ "
    mantain1Temp = "(((mantain1Temp)))"
    mantain2Temp = "(((mantain2Temp)))"
    mantain3Temp = "(((mantain3Temp)))"
  	target = URI.decode(target)
  	target = replace(target,mantain1,mantain1Temp)
  	target = replace(target,mantain2,mantain2Temp)
  	target = replace(target,mantain3,mantain3Temp)
  	target = replace(target,"+"," ")
  	target = replace(target,mantain1Temp,mantain1)
  	target = replace(target,mantain2Temp,mantain2)
  	replace(target,mantain3Temp,mantain3)
  end
  
  
  
  @doc """
  Extract a parameter value of an parameter values array.
  
  Useful in some situations, to handle parameters received from
  a api call for example.
  
  ## Examples

  ```elixir 
  iex > arrayParams = ["name=Johann Backend","age=54","address=404 street"]
  iex > Krug.StringUtil.getDecodedValueParam(arrayParams,"name","=")
  "Johann Backend"
  ```
  ```elixir 
  iex > arrayParams = ["name=Johann Backend","age=54","address=404 street"]
  iex > Krug.StringUtil.getDecodedValueParam(arrayParams,"address","=")
  "404 street"
  ```
  """
  def getDecodedValueParam(arrayParams,param,separator) do
    cond do
      (nil == arrayParams or length(arrayParams) == 0) -> ""
      (String.contains?(hd(arrayParams),"#{param}#{separator}")) 
        -> decodeUri(replace(hd(arrayParams),param <> separator,""))
      true -> getDecodedValueParam(tl(arrayParams),param,separator)
    end
  end
  
  
  
  @doc """
  Receives a value, force to string and completes the value 
  whit left zeros until the ```value``` size == ```size``` parameter value
  received.
  
  Useful for visual formatting and bank services for example.
  
  If ```size``` is nil or <= 0, return the ```value``` received.
  
  If ```size``` is < that ```value``` received size, 
  return the ```value``` received truncated to ```size```.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.leftZeros(nil,5)
  "00000"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftZeros("",5)
  "00000"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftZeros(" ",5)
  "0000 "
  ```
  ```elixir 
  iex > Krug.StringUtil.leftZeros("A",5)
  "0000A"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftZeros("AB",5)
  "000AB"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftZeros(33,5)
  "00033"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftZeros(33.4,5)
  "033.4"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftZeros(33.45,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftZeros(33.456,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftZeros(33.4567,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftZeros(33.45678,5)
  "33.45"
  ```
  """
  def leftZeros(string,size) do
    string = emptyIfNil(string)
    cond do
      (nil == size or !(size > 0)) -> string
      (String.length(string) >= size) -> string |> String.slice(0..size - 1)
      true -> leftZeros(concat("0",string,""),size)
    end
  end
  
  
  
  @doc """
  Receives a value, force to string and completes the value 
  whit right zeros until the ```value``` size == ```size``` parameter value
  received.
  
  Useful for visual formatting and bank services for example.
  
  If ```size``` is nil or <= 0, return the ```value``` received.
  
  If ```size``` is < that ```value``` received size, 
  return the ```value``` received truncated to ```size```.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.rightZeros(nil,5)
  "00000"
  ```
  ```elixir 
  iex > Krug.StringUtil.rightZeros("",5)
  "00000"
  ```
  ```elixir 
  iex > Krug.StringUtil.rightZeros(" ",5)
  " 0000"
  ```
  ```elixir 
  iex > Krug.StringUtil.rightZeros("A",5)
  "A0000"
  ```
  ```elixir 
  iex > Krug.StringUtil.rightZeros("AB",5)
  "AB000"
  ```
  ```elixir 
  iex > Krug.StringUtil.rightZeros(33,5)
  "33000"
  ```
  ```elixir 
  iex > Krug.StringUtil.rightZeros(33.4,5)
  "33.40"
  ```
  ```elixir 
  iex > Krug.StringUtil.rightZeros(33.45,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.rightZeros(33.456,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.rightZeros(33.4567,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.rightZeros(33.45678,5)
  "33.45"
  ```
  """
  def rightZeros(string,size) do
    string = emptyIfNil(string)
    cond do
      (nil == size or !(size > 0)) -> string
      (String.length(string) >= size) -> string |> String.slice(0..size - 1)
      true -> rightZeros(concat(string,"0",""),size)
    end
  end
  
  
  
  @doc """
  Receives a value, force to string and completes the value 
  whit left spaces until the ```value``` size == ```size``` parameter value
  received.
  
  Useful for visual formatting and bank services for example.
  
  If ```size``` is nil or <= 0, return the ```value``` received.
  
  If ```size``` is < that ```value``` received size, 
  return the ```value``` received truncated to ```size```.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.leftSpaces(nil,5)
  "     "
  ```
  ```elixir 
  iex > Krug.StringUtil.leftSpaces("",5)
  "     "
  ```
  ```elixir 
  iex > Krug.StringUtil.leftSpaces(" ",5)
  "     "
  ```
  ```elixir 
  iex > Krug.StringUtil.leftSpaces("A",5)
  "    A"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftSpaces("AB",5)
  "   AB"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftSpaces(33,5)
  "   33"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftSpaces(33.4,5)
  " 33.4"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftSpaces(33.45,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftSpaces(33.456,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftSpaces(33.4567,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.leftSpaces(33.45678,5)
  "33.45"
  ```
  """
  def leftSpaces(string,size) do
    string = emptyIfNil(string)
    cond do
      (nil == size or !(size > 0)) -> string
      (String.length(string) >= size) -> string |> String.slice(0..size - 1)
      true -> leftSpaces(concat(" ",string,""),size)
    end
  end
  
  
  
  @doc """
  Receives a value, force to string and completes the value 
  whit right spaces until the ```value``` size == ```size``` parameter value
  received.
  
  Useful for visual formatting and bank services for example.
  
  If ```size``` is nil or <= 0, return the ```value``` received.
  
  If ```size``` is < that ```value``` received size, 
  return the ```value``` received truncated to ```size```.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.rightSpaces(nil,5)
  "     "
  ```
  ```elixir 
  iex > Krug.StringUtil.rightZeros("",5)
  "     "
  ```
  ```elixir 
  iex > Krug.StringUtil.rightSpaces(" ",5)
  "     "
  ```
  ```elixir 
  iex > Krug.StringUtil.rightSpaces("A",5)
  "A    "
  ```
  ```elixir 
  iex > Krug.StringUtil.rightSpaces("AB",5)
  "AB   "
  ```
  ```elixir 
  iex > Krug.StringUtil.rightSpaces(33,5)
  "33   "
  ```
  ```elixir 
  iex > Krug.StringUtil.rightSpaces(33.4,5)
  "33.4 "
  ```
  ```elixir 
  iex > Krug.StringUtil.rightSpaces(33.45,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.rightSpaces(33.456,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.rightSpaces(33.4567,5)
  "33.45"
  ```
  ```elixir 
  iex > Krug.StringUtil.rightSpaces(33.45678,5)
  "33.45"
  ```
  """
  def rightSpaces(string,size) do
    string = emptyIfNil(string)
    cond do
      (nil == size or !(size > 0)) -> string
      (String.length(string) >= size) -> string |> String.slice(0..size - 1)
      true -> rightSpaces(concat(string," ",""),size)
    end
  end
  
  
  
  @doc """
  Convert a value to string, returning the value whitout left and right spaces.
  
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
    emptyIfNil(string) |> String.trim()
  end
  
  
  
  @doc """
  Convert a value to string, and verify if this value contains one
  value present on received ```array``` of values. Each value on ```array``` of values
  is converted to string before realize the comparison. 
  
  If ```array``` is nil/empty return false.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.containsOneElementOfArray(nil,nil)
  false
  ```
  ```elixir 
  iex > Krug.StringUtil.containsOneElementOfArray("",nil)
  false
  ```
  ```elixir 
  iex > Krug.StringUtil.containsOneElementOfArray(" ",nil)
  false
  ```
  ```elixir 
  iex > Krug.StringUtil.containsOneElementOfArray("abcdef[]",[0,1,2,[]])
  false
  ```
  ```elixir 
  iex > Krug.StringUtil.containsOneElementOfArray("abcdef5",[0,1,2,[5,7]])
  false
  ```
  ```elixir 
  iex > Krug.StringUtil.containsOneElementOfArray("abcdef5,7",[0,1,2,[5,7]])
  false
  ```
  ```elixir 
  iex > Krug.StringUtil.containsOneElementOfArray("abcdef[5,7]",[0,1,2,[5,7]])
  false
  ```
  ```elixir 
  iex > Krug.StringUtil.containsOneElementOfArray("abcdef[]",[0,1,2,[],"]"])
  true
  ```
  ```elixir 
  iex > Krug.StringUtil.containsOneElementOfArray("abcdef[]",[0,1,2,[],"bc"])
  true
  ```
  ```elixir 
  iex > Krug.StringUtil.containsOneElementOfArray("abcdef[]",[0,1,2,[],"def["])
  true
  ```
  ```elixir 
  iex > Krug.StringUtil.containsOneElementOfArray("abcdef8[]",[0,1,2,[],8])
  true
  ```
  """
  def containsOneElementOfArray(target,array) do
    cond do
      (nil == array or length(array) == 0) -> false
      ("#{hd(array)}" == "") -> containsOneElementOfArray(target,tl(array))
      (String.contains?("#{target}","#{hd(array)}")) -> true
      true -> containsOneElementOfArray(target,tl(array))
    end
  end
  
  
  
  @doc """
  Convert a received value to a string. If this string is not empty return these value.
  Otherwise return the ```valueIfEmptyOrNull``` parameter value.
  
  If ```valueIfEmptyOrNull``` is nil return the received value or a empty string
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
  def coalesce(value,valueIfEmptyOrNull) do
    cond do
      (nil == valueIfEmptyOrNull) -> emptyIfNil(value)
      (trim(value) == "") -> valueIfEmptyOrNull
      true -> value
    end
  end
  
  
  
  @doc """
  Convert a numeric value ```charCodeString``` received to the
  correspondent character alfanumeric of any alphabet of
  any language.
  
  Useful in various functionalities that encode/decode chars.
  
  ## Examples

  ```elixir 
  iex > Krug.StringUtil.StringUtil.toChar("")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.StringUtil.toChar(" ")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.StringUtil.toChar("A")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.StringUtil.toChar("AB")
  ""
  ```
  ```elixir 
  iex > Krug.StringUtil.StringUtil.toChar(5)
  "\x05"
  ```
  ```elixir 
  iex > Krug.StringUtil.StringUtil.toChar(65)
  "A"
  ```
  ```elixir 
  iex > Krug.StringUtil.StringUtil.toChar(225)
  "á"
  ```
  ```elixir 
  iex > Krug.StringUtil.StringUtil.toChar(16000)
  "㺀"
  ```
  """
  def toChar(charCodeString) do
    number = NumberUtil.toInteger(charCodeString)
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
  iex > Krug.StringUtil.toCharCode(nil,0) 
  nil
  ```
  ```elixir 
  iex > Krug.StringUtil.toCharCode([],0) 
  nil
  ```
  ```elixir 
  iex > Krug.StringUtil.toCharCode([nil],0) 
  nil
  ```
  ```elixir 
  iex > Krug.StringUtil.toCharCode([""],0) 
  nil
  ```
  ```elixir 
  iex > Krug.StringUtil.toCharCode([""],3) 
  nil
  ```
  ```elixir 
  iex > Krug.StringUtil.toCharCode([" "],0)
  32
  ```
  ```elixir 
  iex > Krug.StringUtil.toCharCode(["\x05"],0)
  5
  ```
  ```elixir 
  iex > Krug.StringUtil.toCharCode(["A"],0)
  65
  ```
  ```elixir 
  iex > Krug.StringUtil.toCharCode(["á"],0)
  225
  ```
  ```elixir 
  iex > Krug.StringUtil.toCharCode(["㺀"],0)
  16000
  ```
  ```elixir 
  iex > Krug.StringUtil.toCharCode([nil,"",3,[],%{},"A"],5)
  65
  ```
  """
  def toCharCode(array,position) do
    cond do
      (nil == array or position >= length(array)) -> nil
      (Enum.member?(["",nil],array |> Enum.at(position))) -> nil
      true -> array |> Enum.at(position) |> toCharCode()
    end
  end
  
  
  
  defp toCharCode(stringChar) do
    stringChar 
      |> emptyIfNil() 
      |> String.to_charlist() 
      |> hd()
  end
  
  
    
end