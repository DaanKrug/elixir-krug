defmodule Krug.ReturnUtil do

  @moduledoc """
  Utilitary module to provide return objects to REST APIs 
  that don't return a list of objects from database.
  """


  
  @doc """
  Return a map object for cases on that the backend operation fail to execute
  (partial or complete). 
  
  Useful to inform a friendly error message to User Interface and do not expose
  critical messages, customized as needed

  ## Examples

  ```elixir 
  iex > Krug.ReturnUtil.get_operation_error()
  %{ 
    objectClass: "OperationError", 
    code: 500, 
    msg: ""
  }
  ```
  ```elixir 
  iex > error_msg = "Operation Failed: impossible to create new user with email: jhon@jhon.com"
  iex > Krug.ReturnUtil.get_operation_error(error_msg)
  %{ 
    objectClass: "OperationError", 
    code: 500, 
    msg: "Operation Failed: impossible to create new user with email: jhon@jhon.com" 
  }
  ```
  """
  def get_operation_error(error_msg \\ "") do
    %{
      objectClass: "OperationError",
      code: 500,
      msg: error_msg
    }
  end
  
  
  
  @doc """
  Return a map object for cases on that the backend excute fully successfull.
  
  Useful to inform a friendly sucess message to User Interface, customized as needed.
  Can return an object as map, for control in user interface.

  ## Examples

  ```elixir 
  iex > return_object = %{name: "Echo Ping", email: "echo@ping.com"}
  iex > Krug.ReturnUtil.get_operation_success(200,"Sucess on Insert",return_object)
  %{ 
    objectClass: "OperationSuccess", 
    code: 200, 
    msg: "Sucess on Insert", 
    object: %{
              name: "Echo Ping", 
              email: "echo@ping.com"
             } 
  }
  ```
  ```elixir 
  iex > Krug.ReturnUtil.get_operation_success(201,"Sucess on Update")
  %{ 
    objectClass: "OperationSuccess", 
    code: 201, 
    msg: "Sucess on Update",
    object: nil 
  }
  ```
  ```elixir 
  iex > return_object = %{oldName: "Echo Ping", name: "Alpha Bravo"}
  iex > Krug.ReturnUtil.get_operation_success(201,"Sucess on Update Name",return_object)
  %{ 
    objectClass: "OperationSuccess", 
    code: 201, 
    msg: "Sucess on Update Name", 
    object: %{
              oldName: "Echo Ping", 
              name: "Alpha Bravo"
             }
  }
  ```
  """
  def get_operation_success(return_code,success_msg,return_object \\ nil) do
    %{
      objectClass: "OperationSuccess",
      code: return_code,
      msg: success_msg,
      object: return_object
    }
  end
  
  
  
  @doc """
  Return a map object for cases on that the backend result false when execute 
  validations (one or more parameters contains invalid characters, the length
  of value of parameter received is bigger than the dabase column field, and others).
  
  Useful to inform a friendly validation message to User Interface, customized as needed.
  
  ## Example

  ```elixir 
  iex > Krug.ReturnUtil.get_validation_result(100100,"[100100] E-mail should be a valid email.")
  %{
    objectClass: "ValidationResult",
    code: 100100,
    msg: "[100100] E-mail should be a valid email."
  }
  ```
  """
  def get_validation_result(return_code,result_msg) do
    %{
      objectClass: "ValidationResult",
      code: return_code,
      msg: result_msg
    }
  end
  
  
  
  @doc """
  Return a array of map objects for cases on that the backend need generate
  some especial content to return to user interface.
  This array is always size == 1. The return need be encapsulated to array,
  to make possible the user interface receive this return in same call scheme
  of the operations that load multiple objects from backend (compatibility).  
  
  Useful for generate custom dynamic content html, or dynamic reports for example.

  ## Example

  ```elixir 
  iex > html = "<h1>This is the Report Header of Generated Report</h1>"
  iex > Krug.ReturnUtil.get_report(html)
  [
    %{
      objectClass: "Report",
      code: 205,
      msg: "<h1>This is the Report Header of Generated Report</h1>"
    }
  ]
  ```
  """
  def get_report(html) do
    [%{
      objectClass: "Report",
      code: 205,
      msg: html
    }]
  end
  


end