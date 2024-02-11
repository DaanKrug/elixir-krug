defmodule Krug.StringUtilTest do
  use ExUnit.Case
  
  doctest Krug.StringUtil
  
  alias Krug.StringUtil
  
  test "[index_of(string,substring,skip_verification \\ false)]" do
    assert StringUtil.index_of("","") == 0
    assert StringUtil.index_of(" ","") == 0
    assert StringUtil.index_of(""," ") == -1
    assert StringUtil.index_of("Today","morning") == -1
    assert StringUtil.index_of("today morning","today") == 0
    assert StringUtil.index_of("today morning","morning") == 6
    assert StringUtil.index_of("today morning",nil) == -1
    assert StringUtil.index_of(nil,"morning") == -1
    assert StringUtil.index_of(nil,nil) == -1
    skip_validation = true
    assert StringUtil.index_of("","",skip_validation) == 0
    assert StringUtil.index_of(" ","",skip_validation) == 0
    assert StringUtil.index_of(""," ",skip_validation) == -1
    assert StringUtil.index_of("Today","morning",skip_validation) == -1
    assert StringUtil.index_of("today morning","today",skip_validation) == 0
    assert StringUtil.index_of("today morning","morning",skip_validation) == 6
  end
  
  test "[raw_binary_to_string(raw_string)]" do
    raw0 = <<65,241,111,32,100,101,32,70,97,99,116>>
    assert StringUtil.raw_binary_to_string(raw0) == "Año de Fact"
    raw1 = "Año de Fact"
    assert StringUtil.raw_binary_to_string(raw1) == "Año de Fact"
    raw2 = "Ano de Fact"
    assert StringUtil.raw_binary_to_string(raw2) == "Ano de Fact"
  end
  
  test "[concat(string_a,string_b,join_string)]" do
    assert StringUtil.concat(nil,nil,nil) == ""
    assert StringUtil.concat(nil,nil,",") == ""
    assert StringUtil.concat("","",",") == ""
    assert StringUtil.concat("A",nil,",") == "A"
    assert StringUtil.concat("A","",",") == "A"
    assert StringUtil.concat("A","B",",") == "A,B"
    assert StringUtil.concat(" ","B",",") == " ,B"
    assert StringUtil.concat(nil,"B",",") == "B"
  end
  
  test "[empty_if_nil(target)]" do
    assert StringUtil.empty_if_nil(nil) == ""
    assert StringUtil.empty_if_nil("") == ""
    assert StringUtil.empty_if_nil(" ") == " "
    assert StringUtil.empty_if_nil("A") == "A"
    assert StringUtil.empty_if_nil(10) == "10"
    assert StringUtil.empty_if_nil(10.05) == "10.05"
    assert StringUtil.empty_if_nil(-10.05) == "-10.05"
  end
  
  test "[slice(string,start,end)]" do
    assert StringUtil.slice("",0,0) == ""
    assert StringUtil.slice("",0,1) == ""
    assert StringUtil.slice("",0,10) == ""
    assert StringUtil.slice(" A ",0,0) == " "
    assert StringUtil.slice(" A ",0,1) == " A"
    assert StringUtil.slice(" A ",0,2) == " A "
    assert StringUtil.slice(" A ",0,10) == " A "
    assert StringUtil.slice(" ABCDEFGHIJ K L M",1,14) == "ABCDEFGHIJ K L"
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
  
  test "[replace(target,searched,replace_to)]" do
    phrase1 = "replace all e letters by C letter"
    phrase1Replaced = "rcplacc all c lcttcrs by C lcttcr"
    phrase2 = "replace non recursive because recursion throwble place"
    phrase2Replaced = "repla[Ace Ventures] non recursive because recursion throwble pla[Ace Ventures]"
    assert StringUtil.replace("aa   bb    cc","  "," ") == "aa bb cc"
    assert StringUtil.replace("aa       bb               cc","  "," ") == "aa bb cc"
    assert StringUtil.replace(phrase1,"e","c") == phrase1Replaced
    assert StringUtil.replace(phrase2,"ce","[Ace Ventures]") == phrase2Replaced
  end
  
  test "[replace_all(target,searched_array,replace_to)]" do
    phrase1 = "replace all e letters by C letter"
    phrase1Replaced = "rcclccc cll c lccccrs by C lccccr"
    phrase2 = "replace non recursive because recursion throwble place"
    phrase2Replaced = """
                      repla[Ace Vent[Ace Ventures]es] non 
                      rec[Ace Ventures]sive because rec[Ace Ventures]sion 
                      throwble pla[Ace Vent[Ace Ventures]es]
                      """
    phrase2Replaced = phrase2Replaced |> StringUtil.trim() |> StringUtil.replace("\n","") 
    assert StringUtil.replace_all("afbfc   bfb    cfdc",["  ","f","c"],"0") == "a0b000 b0b0000d0"
    assert StringUtil.replace_all("aa       bb               cc",["  ","f","c"],"0") == "aa000 bb0000000 00"
    assert StringUtil.replace_all(phrase1,["e","a","p","t"],"c") == phrase1Replaced
    assert StringUtil.replace_all(phrase2,["ce","ur"],"[Ace Ventures]") == phrase2Replaced
  end
  
  test "[decode_uri(target)]" do
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
    assert StringUtil.decode_uri(shortUri) == decodedShortUri
    assert StringUtil.decode_uri(longUri) == decodedLongUri
  end
  
  test "[get_decoded_value_param(array_params,param,separator)]" do
    array_params = ["name=Johann Backend","age=54","address=404 street"]
    assert StringUtil.get_decoded_value_param(array_params,"name","=") == "Johann Backend"
    assert StringUtil.get_decoded_value_param(array_params,"age","=") == "54"
    assert StringUtil.get_decoded_value_param(array_params,"address","=") == "404 street"
  end
  
  test "[left_zeros(string,size)]" do
    assert StringUtil.left_zeros(nil,5) == "00000"
    assert StringUtil.left_zeros("",5) == "00000"
    assert StringUtil.left_zeros(" ",5) == "0000 "
    assert StringUtil.left_zeros("A",5) == "0000A"
    assert StringUtil.left_zeros("AB",5) == "000AB"
    assert StringUtil.left_zeros(33,5) == "00033"
    assert StringUtil.left_zeros(33.4,5) == "033.4"
    assert StringUtil.left_zeros(33.46,5) == "33.46"
    assert StringUtil.left_zeros(33.467,5) == "33.46"
    assert StringUtil.left_zeros(33.4678,5) == "33.46"
  end
  
  test "[right_zeros(string,size)]" do
    assert StringUtil.right_zeros(nil,5) == "00000"
    assert StringUtil.right_zeros("",5) == "00000"
    assert StringUtil.right_zeros(" ",5) == " 0000"
    assert StringUtil.right_zeros("A",5) == "A0000"
    assert StringUtil.right_zeros("AB",5) == "AB000"
    assert StringUtil.right_zeros(33,5) == "33000"
    assert StringUtil.right_zeros(33.4,5) == "33.40"
    assert StringUtil.right_zeros(33.46,5) == "33.46"
    assert StringUtil.right_zeros(33.467,5) == "33.46"
    assert StringUtil.right_zeros(33.4678,5) == "33.46"
  end
  
  test "[left_spaces(string,size)]" do
    assert StringUtil.left_spaces(nil,5) == "     "
    assert StringUtil.left_spaces("",5) == "     "
    assert StringUtil.left_spaces(" ",5) == "     "
    assert StringUtil.left_spaces("A",5) == "    A"
    assert StringUtil.left_spaces("AB",5) == "   AB"
    assert StringUtil.left_spaces(33,5) == "   33"
    assert StringUtil.left_spaces(33.4,5) == " 33.4"
    assert StringUtil.left_spaces(33.46,5) == "33.46"
    assert StringUtil.left_spaces(33.467,5) == "33.46"
    assert StringUtil.left_spaces(33.4678,5) == "33.46"
  end
  
  test "[right_spaces(string,size)]" do
    assert StringUtil.right_spaces(nil,5) == "     "
    assert StringUtil.right_spaces("",5) == "     "
    assert StringUtil.right_spaces(" ",5) == "     "
    assert StringUtil.right_spaces("A",5) == "A    "
    assert StringUtil.right_spaces("AB",5) == "AB   "
    assert StringUtil.right_spaces(33,5) == "33   "
    assert StringUtil.right_spaces(33.4,5) == "33.4 "
    assert StringUtil.right_spaces(33.46,5) == "33.46"
    assert StringUtil.right_spaces(33.467,5) == "33.46"
    assert StringUtil.right_spaces(33.4678,5) == "33.46"
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
  
  test "[contains_one_element_of_array(target,array)]" do
    assert StringUtil.contains_one_element_of_array(nil,nil) == false
    assert StringUtil.contains_one_element_of_array("",nil) == false
    assert StringUtil.contains_one_element_of_array(" ",nil) == false
    assert StringUtil.contains_one_element_of_array("abcdef[]",[0,1,2,[]]) == false
    assert StringUtil.contains_one_element_of_array("abcdef5",[0,1,2,[5,7]]) == false
    assert StringUtil.contains_one_element_of_array("abcdef57",[0,1,2,[5,7]]) == false
    assert StringUtil.contains_one_element_of_array("abcdef5,7",[0,1,2,[5,7]]) == false
    assert StringUtil.contains_one_element_of_array("abcdef[5,7]",[0,1,2,[5,7]]) == false
    assert StringUtil.contains_one_element_of_array("abcdef[]",[0,1,2,[],"["]) == true
    assert StringUtil.contains_one_element_of_array("abcdef[]",[0,1,2,[],"]"]) == true
    assert StringUtil.contains_one_element_of_array("abcdef[]",[0,1,2,[],"ab"]) == true
    assert StringUtil.contains_one_element_of_array("abcdef[]",[0,1,2,[],"bc"]) == true
    assert StringUtil.contains_one_element_of_array("abcdef[]",[0,1,2,[],"def["]) == true
    assert StringUtil.contains_one_element_of_array("abcdef8[]",[0,1,2,[],8]) == true
  end
  
  test "[coalesce(value,value_if_empty_or_nil)]" do
    assert StringUtil.coalesce(nil,nil) == ""
    assert StringUtil.coalesce(nil,"") == ""
    assert StringUtil.coalesce("",nil) == ""
    assert StringUtil.coalesce(" ",nil) == " "
    assert StringUtil.coalesce("A",nil) == "A"
    assert StringUtil.coalesce(nil,"A") == "A"
    assert StringUtil.coalesce("","A") == "A"
    assert StringUtil.coalesce(" ","A") == "A"
  end
  
  test "[to_char(char_code_string)]" do
    assert StringUtil.to_char("") == ""
    assert StringUtil.to_char(" ") == ""
    assert StringUtil.to_char("A") == ""
    assert StringUtil.to_char("B") == ""
    assert StringUtil.to_char("AB") == ""
    assert StringUtil.to_char(5) == "\x05"
    assert StringUtil.to_char(65) == "A"
    assert StringUtil.to_char(225) == "á"
    assert StringUtil.to_char(16000) == "㺀"
  end
  
  test "[to_char_code(array,position)]" do
    assert StringUtil.to_char_code(nil,0) == nil
    assert StringUtil.to_char_code([],0) == nil
    assert StringUtil.to_char_code([""],3) == nil
    assert StringUtil.to_char_code([nil],0) == nil
    assert StringUtil.to_char_code([""],0) == nil
    assert StringUtil.to_char_code([" "],0) == 32
    assert StringUtil.to_char_code(["\x05"],0) == 5
    assert StringUtil.to_char_code(["A"],0) == 65
    assert StringUtil.to_char_code(["á"],0) == 225
    assert StringUtil.to_char_code(["㺀"],0) == 16000
    assert StringUtil.to_char_code([nil,"",3,[],%{},"A"],5) == 65
  end
  
end
















