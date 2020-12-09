defmodule Krug.FileUtilTest do
  use ExUnit.Case
  
  alias Krug.FileUtil
  alias Krug.SanitizerUtil
  
  test "[allFileFunctions]" do
    path = "./echo_#{SanitizerUtil.generateRandomOnlyNum(20)}"
    path2 = "./echo_#{SanitizerUtil.generateRandomOnlyNum(20)}"
    file1 = "./echo.txt"
    file2 = "#{path2}/echo.txt"
    insertionPoints = ["//insertionPointBegin -->","//insertionPointEnd -->"]
    insertionPointTag = "//insertionPoint -->"
    assert FileUtil.createDir(path) == true
    assert FileUtil.createDir(path2) == true
    assert FileUtil.copyFile(file1,file2) == true
    assert FileUtil.readFile(file2) == "AA"
    assert FileUtil.replaceInFile(file2,"A","BB")
    assert FileUtil.readFile(file2) == "BBBB"
    assert FileUtil.write(file2,"CCCC") == true
    assert FileUtil.readFile(file2) == "CCCC"
    assert FileUtil.write(file2,"\n#{insertionPointTag}") == true
    assert FileUtil.write(file2,"Echoo xxx []",insertionPoints,insertionPointTag) == true
    assert FileUtil.remove(file2,insertionPoints) == true
    assert FileUtil.copyDir(path2,path) == true
    assert FileUtil.dropFile(file2) == true
    assert FileUtil.dropDir(path) == true
    assert FileUtil.dropDir(path2) == true
  end
  
end