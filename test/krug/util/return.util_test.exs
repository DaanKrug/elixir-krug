defmodule Krug.ReturnUtilTest do
  use ExUnit.Case
  
  doctest Krug.ReturnUtil
  
  alias Krug.ReturnUtil
  alias Krug.MapUtil
  
  test "[getOperationError(msgError \\\\ \"\")]" do
    map = ReturnUtil.getOperationError()
    map2 = ReturnUtil.getOperationError("One Stupid Error")
    assert map |> MapUtil.get(:objectClass) == "OperationError" 
    assert map |> MapUtil.get(:code) == 500 
    assert map |> MapUtil.get(:msg) == "" 
    assert map2 |> MapUtil.get(:msg) == "One Stupid Error" 
  end
  
  test "[getOperationSuccess(codeReturn,msgSucess,objectReturn \\\\ nil)]" do
    objectReturn = %{echo: "ping"}
    map = ReturnUtil.getOperationSuccess(200,"Sucess Message 200")
    map2 = ReturnUtil.getOperationSuccess(201,"Sucess Message 201",objectReturn)
    assert map |> MapUtil.get(:objectClass) == "OperationSuccess" 
    assert map |> MapUtil.get(:code) == 200 
    assert map |> MapUtil.get(:msg) == "Sucess Message 200" 
    assert map |> MapUtil.get(:object) == nil
    assert map2 |> MapUtil.get(:objectClass) == "OperationSuccess" 
    assert map2 |> MapUtil.get(:code) == 201 
    assert map2 |> MapUtil.get(:msg) == "Sucess Message 201" 
    assert map2 |> MapUtil.get(:object) |> MapUtil.get(:echo) == "ping" 
  end
  
  test "[getValidationResult(codeReturn,msgResult)]" do
    map = ReturnUtil.getValidationResult(100200,"[100200] ValidationMessage")
    assert map |> MapUtil.get(:objectClass) == "ValidationResult" 
    assert map |> MapUtil.get(:code) == 100200 
    assert map |> MapUtil.get(:msg) == "[100200] ValidationMessage" 
  end
  
  test "[getReport(html)]" do
    html = "<div><h1>Echo Ping</h1></div>"
    map = ReturnUtil.getReport(html) |> Enum.at(0)
    assert map |> MapUtil.get(:objectClass) == "Report" 
    assert map |> MapUtil.get(:code) == 205 
    assert map |> MapUtil.get(:msg) == html 
  end
  
  
end