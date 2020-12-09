defmodule Krug.HttpUtilTest do
  use ExUnit.Case
  
  doctest Krug.HttpUtil
  
  alias Krug.HttpUtil
  
  test "[get request]" do
    url = "www.google.com"
    fakeUrl = "www.fakeurl.xxx"
    assert HttpUtil.makeGetRequest(url) |> String.contains?("<!doctype html><html") == true
    assert HttpUtil.makeGetRequest(url,[],[],true) |> String.contains?("<!doctype html><html") == true
    assert HttpUtil.makeGetRequest(fakeUrl) == nil
    assert HttpUtil.makeGetRequest(fakeUrl,[],[],true) == %HTTPoison.Error{id: nil, reason: :nxdomain}
  end
  
  test "[post request]" do
    url = "www.google.com"
    fakeUrl = "www.fakeurl.xxx"
    jsonbody = "{search: \"ping\"}"
    assert HttpUtil.makePostRequest(url,jsonbody) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.makePostRequest(url,jsonbody,[],[],true) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.makePostRequest(fakeUrl,jsonbody) == nil
    assert HttpUtil.makePostRequest(fakeUrl,jsonbody,[],[],true) 
             == %HTTPoison.Error{id: nil, reason: :nxdomain}
  end
  
  test "[put request]" do
    url = "www.google.com"
    fakeUrl = "www.fakeurl.xxx"
    jsonbody = "{search: \"ping\"}"
    assert HttpUtil.makePutRequest(url,jsonbody) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.makePutRequest(url,jsonbody,[],[],true) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.makePutRequest(fakeUrl,jsonbody) == nil
    assert HttpUtil.makePutRequest(fakeUrl,jsonbody,[],[],true) 
             == %HTTPoison.Error{id: nil, reason: :nxdomain}
  end
  
  test "[patch request]" do
    url = "www.google.com"
    fakeUrl = "www.fakeurl.xxx"
    jsonbody = "{search: \"ping\"}"
    assert HttpUtil.makePatchRequest(url,jsonbody) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.makePatchRequest(url,jsonbody,[],[],true) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.makePatchRequest(fakeUrl,jsonbody) == nil
    assert HttpUtil.makePatchRequest(fakeUrl,jsonbody,[],[],true) 
             == %HTTPoison.Error{id: nil, reason: :nxdomain}
  end
  
  test "[delete request]" do
    url = "www.google.com"
    fakeUrl = "www.fakeurl.xxx"
    assert HttpUtil.makeDeleteRequest(url) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.makeDeleteRequest(url,[],[],true) 
             |> String.contains?("Error 405 (Method Not Allowed)") == true
    assert HttpUtil.makeDeleteRequest(fakeUrl) == nil
    assert HttpUtil.makeDeleteRequest(fakeUrl,[],[],true) 
             == %HTTPoison.Error{id: nil, reason: :nxdomain}
  end
  
  
end