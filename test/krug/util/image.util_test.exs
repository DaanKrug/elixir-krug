defmodule Krug.ImageUtilTest do
  use ExUnit.Case
  
  doctest Krug.ImageUtil
  
  alias Krug.ImageUtil
  
  test "[validateUrl(path)]" do
    path = "http://xyz.com"
    path2 = "https://xyz.com"
    path3 = "https://xyz.com.br"
    path4 = "https://xyz"
    path5 = "https://xyz.bmp"
    path6 = "https://xyz.png"
    path7 = "https://xyz.jpeg"
    path8 = "https://xyz.jpg"
    path9 = "https://xyz.gif"
    path10 = "https://xyz.svg"
    assert ImageUtil.validateUrl(path) == false
    assert ImageUtil.validateUrl(path2) == false
    assert ImageUtil.validateUrl(path3) == false
    assert ImageUtil.validateUrl(path4) == false
    assert ImageUtil.validateUrl(path5) == true
    assert ImageUtil.validateUrl(path6) == true
    assert ImageUtil.validateUrl(path7) == true
    assert ImageUtil.validateUrl(path8) == true
    assert ImageUtil.validateUrl(path9) == true
    assert ImageUtil.validateUrl(path10) == false
  end
  
  
end