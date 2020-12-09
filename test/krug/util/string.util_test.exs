defmodule Krug.StringUtilTest do
  use ExUnit.Case
  
  doctest Krug.StringUtil
  
  alias Krug.StringUtil
  
  test "[concat(stringA,stringB,joinString)]" do
    assert StringUtil.concat(nil,nil,nil) == ""
    assert StringUtil.concat(nil,nil,",") == ""
    assert StringUtil.concat("","",",") == ""
    assert StringUtil.concat("A",nil,",") == "A"
    assert StringUtil.concat("A","",",") == "A"
    assert StringUtil.concat("A","B",",") == "A,B"
    assert StringUtil.concat(" ","B",",") == " ,B"
    assert StringUtil.concat(nil,"B",",") == "B"
  end
  
  test "[emptyIfNil(target)]" do
    assert StringUtil.emptyIfNil(nil) == ""
    assert StringUtil.emptyIfNil("") == ""
    assert StringUtil.emptyIfNil(" ") == " "
    assert StringUtil.emptyIfNil("A") == "A"
    assert StringUtil.emptyIfNil(10) == "10"
    assert StringUtil.emptyIfNil(10.05) == "10.05"
    assert StringUtil.emptyIfNil(-10.05) == "-10.05"
  end
  
  test "[split(target,searched)]" do
    assert StringUtil.split(nil,nil) == []
    assert StringUtil.split(nil,"") == []
    assert StringUtil.split("",nil) == [""]
    assert StringUtil.split("","") == [""]
    assert StringUtil.split("ABC","") == ["ABC"]
    assert StringUtil.split("ABC",nil) == ["ABC"]
    assert StringUtil.split("ABC"," ") == ["ABC"]
    assert StringUtil.split("ABC","-") == ["ABC"]
    assert StringUtil.split("A-B-C","-") == ["A","B","C"]
    assert StringUtil.split(" A-B-C","-") == [" A","B","C"]
    assert StringUtil.split(" A-B-C ","-") == [" A","B","C "]
    assert StringUtil.split("-A-B-C-","-") == ["","A","B","C",""]
  end
  
  test "[capitalize(target)]" do
    assert StringUtil.capitalize(nil) == ""
    assert StringUtil.capitalize("") == ""
    assert StringUtil.capitalize(" ") == " "
    assert StringUtil.capitalize(" a e i ou ") == " A E I Ou "
    assert StringUtil.capitalize(" this is a method that capitalize ") == " This Is A Method That Capitalize "
  end
  
  test "[replace(target,searched,replaceTo)]" do
    phrase1 = "replace all e letters by C letter"
    phrase1Replaced = "rcplacc all c lcttcrs by C lcttcr"
    phrase2 = "replace non recursive because recursion throwble place"
    phrase2Replaced = "repla[Ace Ventures] non recursive because recursion throwble pla[Ace Ventures]"
    assert StringUtil.replace("aa   bb    cc","  "," ") == "aa bb cc"
    assert StringUtil.replace("aa       bb               cc","  "," ") == "aa bb cc"
    assert StringUtil.replace(phrase1,"e","c") == phrase1Replaced
    assert StringUtil.replace(phrase2,"ce","[Ace Ventures]") == phrase2Replaced
  end
  
  test "[replaceAll(target,searchedArray,replaceTo)]" do
    phrase1 = "replace all e letters by C letter"
    phrase1Replaced = "rcclccc cll c lccccrs by C lccccr"
    phrase2 = "replace non recursive because recursion throwble place"
    phrase2Replaced = """
                      repla[Ace Vent[Ace Ventures]es] non 
                      rec[Ace Ventures]sive because rec[Ace Ventures]sion 
                      throwble pla[Ace Vent[Ace Ventures]es]
                      """
    phrase2Replaced = phrase2Replaced |> StringUtil.trim() |> StringUtil.replace("\n","") 
    assert StringUtil.replaceAll("afbfc   bfb    cfdc",["  ","f","c"],"0") == "a0b000 b0b0000d0"
    assert StringUtil.replaceAll("aa       bb               cc",["  ","f","c"],"0") == "aa000 bb0000000 00"
    assert StringUtil.replaceAll(phrase1,["e","a","p","t"],"c") == phrase1Replaced
    assert StringUtil.replaceAll(phrase2,["ce","ur"],"[Ace Ventures]") == phrase2Replaced
  end
  
  test "[decodeUri(target)]" do
    shortUri = "these ++ is ++ a ++ http://example.com/short+uri+example ++++"
    decodedShortUri = "these ++ is ++ a ++ http://example.com/short uri example +   "
    longUri = """
              + these is a http://example.com/short+uri+example 
              ++ a long uri http://example.com/2020+10+10+the+first+flight+of+
              the+second+model+of+the+third+national+factory
              """
    longUri = longUri |> StringUtil.trim() |> StringUtil.replace("\n","")
    decodedLongUri = """
                     + these is a http://example.com/short uri example ++ a long uri 
                     http://example.com/2020 10 10 the first 
                     flight of the second model of the third national factory
                     """
    decodedLongUri = decodedLongUri |> StringUtil.trim() |> StringUtil.replace("\n","")
    assert StringUtil.decodeUri(shortUri) == decodedShortUri
    assert StringUtil.decodeUri(longUri) == decodedLongUri
  end
  
  test "[getDecodedValueParam(arrayParams,param,separator)]" do
    arrayParams = ["name=Johann Backend","age=54","address=404 street"]
    assert StringUtil.getDecodedValueParam(arrayParams,"name","=") == "Johann Backend"
    assert StringUtil.getDecodedValueParam(arrayParams,"age","=") == "54"
    assert StringUtil.getDecodedValueParam(arrayParams,"address","=") == "404 street"
  end
  
  test "[leftZeros(string,size)]" do
    assert StringUtil.leftZeros(nil,5) == "00000"
    assert StringUtil.leftZeros("",5) == "00000"
    assert StringUtil.leftZeros(" ",5) == "0000 "
    assert StringUtil.leftZeros("A",5) == "0000A"
    assert StringUtil.leftZeros("AB",5) == "000AB"
    assert StringUtil.leftZeros(33,5) == "00033"
    assert StringUtil.leftZeros(33.4,5) == "033.4"
    assert StringUtil.leftZeros(33.46,5) == "33.46"
    assert StringUtil.leftZeros(33.467,5) == "33.46"
    assert StringUtil.leftZeros(33.4678,5) == "33.46"
  end
  
  test "[rightZeros(string,size)]" do
    assert StringUtil.rightZeros(nil,5) == "00000"
    assert StringUtil.rightZeros("",5) == "00000"
    assert StringUtil.rightZeros(" ",5) == " 0000"
    assert StringUtil.rightZeros("A",5) == "A0000"
    assert StringUtil.rightZeros("AB",5) == "AB000"
    assert StringUtil.rightZeros(33,5) == "33000"
    assert StringUtil.rightZeros(33.4,5) == "33.40"
    assert StringUtil.rightZeros(33.46,5) == "33.46"
    assert StringUtil.rightZeros(33.467,5) == "33.46"
    assert StringUtil.rightZeros(33.4678,5) == "33.46"
  end
  
  test "[leftSpaces(string,size)]" do
    assert StringUtil.leftSpaces(nil,5) == "     "
    assert StringUtil.leftSpaces("",5) == "     "
    assert StringUtil.leftSpaces(" ",5) == "     "
    assert StringUtil.leftSpaces("A",5) == "    A"
    assert StringUtil.leftSpaces("AB",5) == "   AB"
    assert StringUtil.leftSpaces(33,5) == "   33"
    assert StringUtil.leftSpaces(33.4,5) == " 33.4"
    assert StringUtil.leftSpaces(33.46,5) == "33.46"
    assert StringUtil.leftSpaces(33.467,5) == "33.46"
    assert StringUtil.leftSpaces(33.4678,5) == "33.46"
  end
  
  test "[rightSpaces(string,size)]" do
    assert StringUtil.rightSpaces(nil,5) == "     "
    assert StringUtil.rightSpaces("",5) == "     "
    assert StringUtil.rightSpaces(" ",5) == "     "
    assert StringUtil.rightSpaces("A",5) == "A    "
    assert StringUtil.rightSpaces("AB",5) == "AB   "
    assert StringUtil.rightSpaces(33,5) == "33   "
    assert StringUtil.rightSpaces(33.4,5) == "33.4 "
    assert StringUtil.rightSpaces(33.46,5) == "33.46"
    assert StringUtil.rightSpaces(33.467,5) == "33.46"
    assert StringUtil.rightSpaces(33.4678,5) == "33.46"
  end
  
  test "[trim(string)]" do
    assert StringUtil.trim(nil) == ""
    assert StringUtil.trim("") == ""
    assert StringUtil.trim(" ") == ""
    assert StringUtil.trim(10) == "10"
    assert StringUtil.trim(10.5) == "10.5"
    assert StringUtil.trim(" 10") == "10"
    assert StringUtil.trim(" 10.5 ") == "10.5"
  end
  
  test "[containsOneElementOfArray(target,array)]" do
    assert StringUtil.containsOneElementOfArray(nil,nil) == false
    assert StringUtil.containsOneElementOfArray("",nil) == false
    assert StringUtil.containsOneElementOfArray(" ",nil) == false
    assert StringUtil.containsOneElementOfArray("abcdef[]",[0,1,2,[]]) == false
    assert StringUtil.containsOneElementOfArray("abcdef5",[0,1,2,[5,7]]) == false
    assert StringUtil.containsOneElementOfArray("abcdef57",[0,1,2,[5,7]]) == false
    assert StringUtil.containsOneElementOfArray("abcdef5,7",[0,1,2,[5,7]]) == false
    assert StringUtil.containsOneElementOfArray("abcdef[5,7]",[0,1,2,[5,7]]) == false
    assert StringUtil.containsOneElementOfArray("abcdef[]",[0,1,2,[],"["]) == true
    assert StringUtil.containsOneElementOfArray("abcdef[]",[0,1,2,[],"]"]) == true
    assert StringUtil.containsOneElementOfArray("abcdef[]",[0,1,2,[],"ab"]) == true
    assert StringUtil.containsOneElementOfArray("abcdef[]",[0,1,2,[],"bc"]) == true
    assert StringUtil.containsOneElementOfArray("abcdef[]",[0,1,2,[],"def["]) == true
    assert StringUtil.containsOneElementOfArray("abcdef8[]",[0,1,2,[],8]) == true
  end
  
  test "[coalesce(value,valueIfEmptyOrNull)]" do
    assert StringUtil.coalesce(nil,nil) == ""
    assert StringUtil.coalesce(nil,"") == ""
    assert StringUtil.coalesce("",nil) == ""
    assert StringUtil.coalesce(" ",nil) == " "
    assert StringUtil.coalesce("A",nil) == "A"
    assert StringUtil.coalesce(nil,"A") == "A"
    assert StringUtil.coalesce("","A") == "A"
    assert StringUtil.coalesce(" ","A") == "A"
  end
  
  test "[toChar(charCodeString)]" do
    assert StringUtil.toChar("") == ""
    assert StringUtil.toChar(" ") == ""
    assert StringUtil.toChar("A") == ""
    assert StringUtil.toChar("B") == ""
    assert StringUtil.toChar("AB") == ""
    assert StringUtil.toChar(5) == "\x05"
    assert StringUtil.toChar(65) == "A"
    assert StringUtil.toChar(225) == "á"
    assert StringUtil.toChar(16000) == "㺀"
  end
  
  test "[toCharCode(array,position)]" do
    assert StringUtil.toCharCode(nil,0) == nil
    assert StringUtil.toCharCode([],0) == nil
    assert StringUtil.toCharCode([""],3) == nil
    assert StringUtil.toCharCode([nil],0) == nil
    assert StringUtil.toCharCode([""],0) == nil
    assert StringUtil.toCharCode([" "],0) == 32
    assert StringUtil.toCharCode(["\x05"],0) == 5
    assert StringUtil.toCharCode(["A"],0) == 65
    assert StringUtil.toCharCode(["á"],0) == 225
    assert StringUtil.toCharCode(["㺀"],0) == 16000
    assert StringUtil.toCharCode([nil,"",3,[],%{},"A"],5) == 65
  end
  
end
















