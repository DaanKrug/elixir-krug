defmodule Krug.SanitizerUtilTest do
  use ExUnit.Case
  
  doctest Krug.SanitizerUtil
  
  alias Krug.SanitizerUtil
  
  test "[validateEmail(email)]" do
    assert SanitizerUtil.validateEmail(nil) == false
    assert SanitizerUtil.validateEmail("") == false
    assert SanitizerUtil.validateEmail([]) == false
    assert SanitizerUtil.validateEmail([""]) == false
    assert SanitizerUtil.validateEmail("echo@ping%com") == false
    assert SanitizerUtil.validateEmail("echo@ping$com") == false
    assert SanitizerUtil.validateEmail("echo@ping.com") == true
    assert SanitizerUtil.validateEmail("echo@ping_com") == true
  end
  
  test "[validateUrl(url)]" do
    assert SanitizerUtil.validateUrl(nil) == false
    assert SanitizerUtil.validateUrl("") == false
    assert SanitizerUtil.validateUrl(" ") == false
    assert SanitizerUtil.validateUrl([]) == false
    assert SanitizerUtil.validateUrl([""]) == false
    assert SanitizerUtil.validateUrl("www.google.com") == false
    assert SanitizerUtil.validateUrl("http://www.google.com") == true
    assert SanitizerUtil.validateUrl("https://www.google.com") == true
    assert SanitizerUtil.validateUrl("https://www.echo|") == false
  end
  
  test "[hasEmpty(arrayValues)]" do
    assert SanitizerUtil.hasEmpty(nil) == false
    assert SanitizerUtil.hasEmpty([]) == false
    assert SanitizerUtil.hasEmpty([nil,1,2]) == true
    assert SanitizerUtil.hasEmpty([3,4,""]) == true
    assert SanitizerUtil.hasEmpty([8,7,9," "]) == true
    assert SanitizerUtil.hasEmpty([[],%{},9,34,"$A"]) == false
  end
  
  test "[hasLessThan(arrayValues,value)]" do
    assert SanitizerUtil.hasLessThan(nil,1) == true
    assert SanitizerUtil.hasLessThan([""],1) == false
    assert SanitizerUtil.hasLessThan([nil],1) == false
    assert SanitizerUtil.hasLessThan([1],nil) == false
    assert SanitizerUtil.hasLessThan([1],"") == false
    assert SanitizerUtil.hasLessThan([1],"-1-1") == false
    assert SanitizerUtil.hasLessThan([1],"10") == true
    assert SanitizerUtil.hasLessThan([1,0],1) == true
    assert SanitizerUtil.hasLessThan([1,0,-1],"-0.5") == true
    assert SanitizerUtil.hasLessThan([1,0,-1],"-0,5.5") == false
    assert SanitizerUtil.hasLessThan([1,0,-1],"-0,0.5") == true
    assert SanitizerUtil.hasLessThan([1,0,-1,[],nil,%{}],"-0,0.5") == true
    assert SanitizerUtil.hasLessThan([1,0,2,[],nil,%{}],"-0,0.5") == false
  end
  
  test "[generateRandom(size)]" do
    rand1 = SanitizerUtil.generateRandom(nil)
    rand2 = SanitizerUtil.generateRandom("")
    rand3 = SanitizerUtil.generateRandom(" ")
    rand4 = SanitizerUtil.generateRandom(10)
    rand5 = SanitizerUtil.generateRandom(20)
    rand6 = SanitizerUtil.generateRandom(30)
    rand7 = SanitizerUtil.generateRandom("10")
    rand8 = SanitizerUtil.generateRandom("20")
    rand9 = SanitizerUtil.generateRandom("30")
    assert rand1 |> String.length() == 10
    assert rand2 |> String.length() == 10
    assert rand3 |> String.length() == 10
    assert rand4 |> String.length() == 10
    assert rand5 |> String.length() == 20
    assert rand6 |> String.length() == 30
    assert rand7 |> String.length() == 10
    assert rand8 |> String.length() == 20
    assert rand9 |> String.length() == 30
    assert rand1 |> SanitizerUtil.sanitizeAll(false,true,10,"A-z0-9") == rand1
    assert rand2 |> SanitizerUtil.sanitizeAll(false,true,10,"A-z0-9") == rand2
    assert rand3 |> SanitizerUtil.sanitizeAll(false,true,10,"A-z0-9") == rand3
    assert rand4 |> SanitizerUtil.sanitizeAll(false,true,10,"A-z0-9") == rand4
    assert rand5 |> SanitizerUtil.sanitizeAll(false,true,20,"A-z0-9") == rand5
    assert rand6 |> SanitizerUtil.sanitizeAll(false,true,30,"A-z0-9") == rand6
    assert rand7 |> SanitizerUtil.sanitizeAll(false,true,10,"A-z0-9") == rand7
    assert rand8 |> SanitizerUtil.sanitizeAll(false,true,20,"A-z0-9") == rand8
    assert rand9 |> SanitizerUtil.sanitizeAll(false,true,30,"A-z0-9") == rand9
  end
  
  test "[generateRandomOnlyNum(size)]" do
    rand1 = SanitizerUtil.generateRandomOnlyNum(nil)
    rand2 = SanitizerUtil.generateRandomOnlyNum("")
    rand3 = SanitizerUtil.generateRandomOnlyNum(" ")
    rand4 = SanitizerUtil.generateRandomOnlyNum(10)
    rand5 = SanitizerUtil.generateRandomOnlyNum(20)
    rand6 = SanitizerUtil.generateRandomOnlyNum(30)
    rand7 = SanitizerUtil.generateRandomOnlyNum("10")
    rand8 = SanitizerUtil.generateRandomOnlyNum("20")
    rand9 = SanitizerUtil.generateRandomOnlyNum("30")
    assert rand1 |> String.length() == 10
    assert rand2 |> String.length() == 10
    assert rand3 |> String.length() == 10
    assert rand4 |> String.length() == 10
    assert rand5 |> String.length() == 20
    assert rand6 |> String.length() == 30
    assert rand7 |> String.length() == 10
    assert rand8 |> String.length() == 20
    assert rand9 |> String.length() == 30
    assert rand1 |> SanitizerUtil.sanitizeAll(false,true,10,"0-9") == rand1
    assert rand2 |> SanitizerUtil.sanitizeAll(false,true,10,"0-9") == rand2
    assert rand3 |> SanitizerUtil.sanitizeAll(false,true,10,"0-9") == rand3
    assert rand4 |> SanitizerUtil.sanitizeAll(false,true,10,"0-9") == rand4
    assert rand5 |> SanitizerUtil.sanitizeAll(false,true,20,"0-9") == rand5
    assert rand6 |> SanitizerUtil.sanitizeAll(false,true,30,"0-9") == rand6
    assert rand7 |> SanitizerUtil.sanitizeAll(false,true,10,"0-9") == rand7
    assert rand8 |> SanitizerUtil.sanitizeAll(false,true,20,"0-9") == rand8
    assert rand9 |> SanitizerUtil.sanitizeAll(false,true,30,"0-9") == rand9
  end
  
  test "[generateRandomFileName(size)]" do
    rand1 = SanitizerUtil.generateRandomFileName(nil)
    rand2 = SanitizerUtil.generateRandomFileName("")
    rand3 = SanitizerUtil.generateRandomFileName(" ")
    rand4 = SanitizerUtil.generateRandomFileName(10)
    rand5 = SanitizerUtil.generateRandomFileName(20)
    rand6 = SanitizerUtil.generateRandomFileName(30)
    rand7 = SanitizerUtil.generateRandomFileName("10")
    rand8 = SanitizerUtil.generateRandomFileName("20")
    rand9 = SanitizerUtil.generateRandomFileName("30")
    assert rand1 |> String.length() == 10
    assert rand2 |> String.length() == 10
    assert rand3 |> String.length() == 10
    assert rand4 |> String.length() == 10
    assert rand5 |> String.length() == 20
    assert rand6 |> String.length() == 30
    assert rand7 |> String.length() == 10
    assert rand8 |> String.length() == 20
    assert rand9 |> String.length() == 30
    assert rand1 |> SanitizerUtil.sanitizeAll(false,true,10,"filename") == rand1
    assert rand2 |> SanitizerUtil.sanitizeAll(false,true,10,"filename") == rand2
    assert rand3 |> SanitizerUtil.sanitizeAll(false,true,10,"filename") == rand3
    assert rand4 |> SanitizerUtil.sanitizeAll(false,true,10,"filename") == rand4
    assert rand5 |> SanitizerUtil.sanitizeAll(false,true,20,"filename") == rand5
    assert rand6 |> SanitizerUtil.sanitizeAll(false,true,30,"filename") == rand6
    assert rand7 |> SanitizerUtil.sanitizeAll(false,true,10,"filename") == rand7
    assert rand8 |> SanitizerUtil.sanitizeAll(false,true,20,"filename") == rand8
    assert rand9 |> SanitizerUtil.sanitizeAll(false,true,30,"filename") == rand9
  end
  
  test "[sanitize(input)]" do
    assert SanitizerUtil.sanitize("echo <script echo") == nil
    assert SanitizerUtil.sanitize("echo < script echo") == nil
    assert SanitizerUtil.sanitize("echo script> echo") == nil
    assert SanitizerUtil.sanitize("echo script > echo") == nil
    assert SanitizerUtil.sanitize("echoscript>echo") == nil
    assert SanitizerUtil.sanitize("echoscriptecho") == "echoscriptecho"
  end
  
  test "[sanitizeAll(input,isNumber,sanitizeInput,maxSize,validChars)]" do
    assert SanitizerUtil.sanitizeAll("09 8778 987",false,true,250,"0-9") == ""
    assert SanitizerUtil.sanitizeAll("098778987",false,true,250,"0-9") == "098778987"
    assert SanitizerUtil.sanitizeAll("09 8778 987",true,true,250,"0-9") == "0"
    assert SanitizerUtil.sanitizeAll("098778987",true,true,250,"0-9") == "098778987"
    assert SanitizerUtil.sanitizeAll("09 8778 987 ABCDEF ",false,true,250,"A-z") == ""
    assert SanitizerUtil.sanitizeAll("09 8778 987 ABCDEF ",false,true,250,"0-9") == ""
    assert SanitizerUtil.sanitizeAll("09 8778 987 ABCDEF ",false,true,250,"A-z0-9") == "09 8778 987 ABCDEF"
  end
  
  test "[sanitizeFileName(name,maxSize)]" do
    assert SanitizerUtil.sanitizeFileName(nil,10) != ""
    assert SanitizerUtil.sanitizeFileName("",10) != ""
    assert SanitizerUtil.sanitizeFileName(" ",10) != ""
    assert SanitizerUtil.sanitizeFileName(" afdd#%%{}8989nfdfdd@",10) != " afdd#%%{}8989nfdfdd@"
    assert SanitizerUtil.sanitizeFileName("afdd#%%{}8989nfdfdd@",100) != " afdd#%%{}8989nfdfdd@"
    assert SanitizerUtil.sanitizeFileName("Aabcde_fg.6712.89_as",10) != "Aabcde_fg."
    assert SanitizerUtil.sanitizeFileName("Aabcde_fg.6712.89_as",15) != "Aabcde_fg.6712."
    assert SanitizerUtil.sanitizeFileName("Aabcde_fg.6712.89_as",19) != "Aabcde_fg.6712.89_a"
    assert SanitizerUtil.sanitizeFileName("Aabcde_fg.6712.89_as",20) == "Aabcde_fg.6712.89_as"
    assert SanitizerUtil.sanitizeFileName("Aabcde_fg.6712.89_as",50) == "Aabcde_fg.6712.89_as"
    assert SanitizerUtil.sanitizeFileName("Aabcde_fg.6712.89_as",100) == "Aabcde_fg.6712.89_as"
  end
  
  test "[nums()]" do
    assert SanitizerUtil.nums() == ["-",".","0","1","2","3","4","5","6","7","8","9"]
  end
  
  test "[onlyNums()]" do
    assert SanitizerUtil.onlyNums() == ["0","1","2","3","4","5","6","7","8","9"]
  end
  
  test "[moneyChars()]" do
    assert SanitizerUtil.moneyChars() == [",","0","1","2","3","4","5","6","7","8","9"]
  end
  
end