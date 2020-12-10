defmodule Krug.ImageUtilTest do
  use ExUnit.Case
  
  doctest Krug.ImageUtil
  
  alias Krug.ImageUtil
  
  test "[validate_url(path)]" do
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
    assert ImageUtil.validate_url(path) == false
    assert ImageUtil.validate_url(path2) == false
    assert ImageUtil.validate_url(path3) == false
    assert ImageUtil.validate_url(path4) == false
    assert ImageUtil.validate_url(path5) == true
    assert ImageUtil.validate_url(path6) == true
    assert ImageUtil.validate_url(path7) == true
    assert ImageUtil.validate_url(path8) == true
    assert ImageUtil.validate_url(path9) == true
    assert ImageUtil.validate_url(path10) == false
  end
  
  
end