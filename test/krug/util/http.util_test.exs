defmodule Krug.HttpUtilTest do
  use ExUnit.Case
  
  doctest Krug.HttpUtil
  
  alias Krug.HttpUtil
  
  test "[get request]" do
    url = "www.google.com"
    fake_url = "www.fake_url.xxx"
    assert HttpUtil.make_get_request(url) |> String.contains?("<!doctype html><html") == true
    assert HttpUtil.make_get_request(url,[],[],true) |> String.contains?("<!doctype html><html") == true
    assert HttpUtil.make_get_request(fake_url) == nil
    assert HttpUtil.make_get_request(fake_url,[],[],true) == %HTTPoison.Error{id: nil, reason: :nxdomain}
  end
  
  test "[post request]" do
    url = "www.google.com"
    fake_url = "www.fake_url.xxx"
    json_body = "{search: \"ping\"}"
    assert HttpUtil.make_post_request(url,json_body) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.make_post_request(url,json_body,[],[],true) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.make_post_request(fake_url,json_body) == nil
    assert HttpUtil.make_post_request(fake_url,json_body,[],[],true) 
             == %HTTPoison.Error{id: nil, reason: :nxdomain}
  end
  
  test "[put request]" do
    url = "www.google.com"
    fake_url = "www.fake_url.xxx"
    json_body = "{search: \"ping\"}"
    assert HttpUtil.make_put_request(url,json_body) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.make_put_request(url,json_body,[],[],true) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.make_put_request(fake_url,json_body) == nil
    assert HttpUtil.make_put_request(fake_url,json_body,[],[],true) 
             == %HTTPoison.Error{id: nil, reason: :nxdomain}
  end
  
  test "[patch request]" do
    url = "www.google.com"
    fake_url = "www.fake_url.xxx"
    json_body = "{search: \"ping\"}"
    assert HttpUtil.make_patch_request(url,json_body) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.make_patch_request(url,json_body,[],[],true) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.make_patch_request(fake_url,json_body) == nil
    assert HttpUtil.make_patch_request(fake_url,json_body,[],[],true) 
             == %HTTPoison.Error{id: nil, reason: :nxdomain}
  end
  
  test "[delete request]" do
    url = "www.google.com"
    fake_url = "www.fake_url.xxx"
    assert HttpUtil.make_delete_request(url) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.make_delete_request(url,[],[],true) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.make_delete_request(fake_url) == nil
    assert HttpUtil.make_delete_request(fake_url,[],[],true) 
             == %HTTPoison.Error{id: nil, reason: :nxdomain}
  end
  
  
end