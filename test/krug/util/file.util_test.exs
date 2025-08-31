defmodule Krug.FileUtilTest do
  use ExUnit.Case
  
  alias Krug.FileUtil
  alias Krug.SanitizerUtil
  
  test "[allFileFunctions]" do
    path = "./echo_#{SanitizerUtil.generate_random_only_num(20)}"
    path2 = "./echo_#{SanitizerUtil.generate_random_only_num(20)}"
    file1 = "./echo.txt"
    file2 = "#{path2}/echo.txt"
    insertion_points = ["//insertionPointBegin -->","//insertionPointEnd -->"]
    insertion_point_tag = "//insertionPoint -->"
    assert FileUtil.create_dir(path) == true
    assert FileUtil.create_dir(path2) == true
    assert FileUtil.write(file1,"AA") == true
    assert FileUtil.write(file2,"") == true
    assert FileUtil.copy_file(file1,file2) == true
    assert FileUtil.read_file(file2) == "AA"
    assert FileUtil.replace_in_file(file2,"A","BB")
    assert FileUtil.read_file(file2) == "BBBB"
    assert FileUtil.write(file2,"CCCC") == true
    assert FileUtil.read_file(file2) == "CCCC"
    assert FileUtil.write(file2,"\n#{insertion_point_tag}") == true
    assert FileUtil.write(file2,"Echoo xxx []",insertion_points,insertion_point_tag) == true
    assert FileUtil.remove(file2,insertion_points) == true
    assert FileUtil.copy_dir(path2,path) == true
    assert FileUtil.drop_file(file2) == true
    assert FileUtil.drop_dir(path) == true
    assert FileUtil.drop_dir(path2) == true
  end
  
  test "[zip_dir empty]" do
    path = "./echo_#{SanitizerUtil.generate_random_only_num(20)}"
    path_zip = "#{path}.zip"
    assert FileUtil.create_dir(path) == true
    assert FileUtil.zip_dir(path) == true
    assert FileUtil.zip_dir(path) == false
    assert FileUtil.zip_dir(path,true) == true
    assert FileUtil.drop_file(path_zip) == true
    assert FileUtil.zip_dir(path) == true
    assert FileUtil.drop_file(path_zip) == true
    assert FileUtil.zip_dir(path) == true
    assert FileUtil.drop_file(path_zip) == true
    assert FileUtil.drop_dir(path) == true
  end
  
  test "[zip_dir not empty]" do
    path = "./echo_#{SanitizerUtil.generate_random_only_num(20)}"
    path_zip = "#{path}.zip"
    file1 = "./echo.txt"
    file2 = "#{path}/echo.txt"
    assert FileUtil.create_dir(path) == true
    assert FileUtil.write(file1,"AA") == true
    assert FileUtil.write(file2,"") == true
    assert FileUtil.copy_file(file1,file2) == true
    assert FileUtil.zip_dir(path) == true
    assert FileUtil.zip_dir(path) == false
    assert FileUtil.zip_dir(path,true) == true
    assert FileUtil.drop_file(path_zip) == true
    assert FileUtil.zip_dir(path) == true
    assert FileUtil.drop_file(path_zip) == true
    assert FileUtil.zip_dir(path) == true
    assert FileUtil.drop_file(path_zip) == true
    assert FileUtil.drop_dir(path) == true
  end
  
end