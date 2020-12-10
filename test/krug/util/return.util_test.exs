defmodule Krug.ReturnUtilTest do
  use ExUnit.Case
  
  doctest Krug.ReturnUtil
  
  alias Krug.ReturnUtil
  alias Krug.MapUtil
  
  test "[get_operation_error(error_msg \\\\ \"\")]" do
    map = ReturnUtil.get_operation_error()
    map2 = ReturnUtil.get_operation_error("One Stupid Error")
    assert map |> MapUtil.get(:objectClass) == "OperationError" 
    assert map |> MapUtil.get(:code) == 500 
    assert map |> MapUtil.get(:msg) == "" 
    assert map2 |> MapUtil.get(:msg) == "One Stupid Error" 
  end
  
  test "[get_operation_success(return_code,success_msg,return_object \\\\ nil)]" do
    return_object = %{echo: "ping"}
    map = ReturnUtil.get_operation_success(200,"Sucess Message 200")
    map2 = ReturnUtil.get_operation_success(201,"Sucess Message 201",return_object)
    assert map |> MapUtil.get(:objectClass) == "OperationSuccess" 
    assert map |> MapUtil.get(:code) == 200 
    assert map |> MapUtil.get(:msg) == "Sucess Message 200" 
    assert map |> MapUtil.get(:object) == nil
    assert map2 |> MapUtil.get(:objectClass) == "OperationSuccess" 
    assert map2 |> MapUtil.get(:code) == 201 
    assert map2 |> MapUtil.get(:msg) == "Sucess Message 201" 
    assert map2 |> MapUtil.get(:object) |> MapUtil.get(:echo) == "ping" 
  end
  
  test "[get_validation_result(return_code,result_msg)]" do
    map = ReturnUtil.get_validation_result(100200,"[100200] ValidationMessage")
    assert map |> MapUtil.get(:objectClass) == "ValidationResult" 
    assert map |> MapUtil.get(:code) == 100200 
    assert map |> MapUtil.get(:msg) == "[100200] ValidationMessage" 
  end
  
  test "[get_report(html)]" do
    html = "<div><h1>Echo Ping</h1></div>"
    map = ReturnUtil.get_report(html) |> Enum.at(0)
    assert map |> MapUtil.get(:objectClass) == "Report" 
    assert map |> MapUtil.get(:code) == 205 
    assert map |> MapUtil.get(:msg) == html 
  end
  
  
end