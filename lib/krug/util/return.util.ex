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
  iex > Krug.ReturnUtil.getOperationError()
  %{ 
    objectClass: "OperationError", 
    code: 500, 
    msg: ""
  }
  ```
  ```elixir 
  iex > errorMsg = "Operation Failed: impossible to create new user whit email: jhon@jhon.com"
  iex > Krug.ReturnUtil.getOperationError(errorMsg)
  %{ 
    objectClass: "OperationError", 
    code: 500, 
    msg: "Operation Failed: impossible to create new user whit email: jhon@jhon.com" 
  }
  ```
  """
  def getOperationError(msgError \\ "") do
    %{
      objectClass: "OperationError",
      code: 500,
      msg: msgError
    }
  end
  
  
  
  @doc """
  Return a map object for cases on that the backend excute fully successfull.
  
  Useful to inform a friendly sucess message to User Interface, customized as needed.
  Can return an object as map, for control in user interface.

  ## Examples

  ```elixir 
  iex > objectReturn = %{name: "Echo Ping", email: "echo@ping.com"}
  iex > Krug.ReturnUtil.getOperationSuccess(200,"Sucess on Insert",objectReturn)
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
  iex > Krug.ReturnUtil.getOperationSuccess(201,"Sucess on Update")
  %{ 
    objectClass: "OperationSuccess", 
    code: 201, 
    msg: "Sucess on Update",
    object: nil 
  }
  ```
  ```elixir 
  iex > objectReturn = %{oldName: "Echo Ping", name: "Alpha Bravo"}
  iex > Krug.ReturnUtil.getOperationSuccess(201,"Sucess on Update Name",objectReturn)
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
  def getOperationSuccess(codeReturn,msgSucess,objectReturn \\ nil) do
    %{
      objectClass: "OperationSuccess",
      code: codeReturn,
      msg: msgSucess,
      object: objectReturn
    }
  end
  
  
  
  @doc """
  Return a map object for cases on that the backend fail to execute 
  validations (one or more parameters contains invalid characters, the length
  of value of parameter received is bigger than the dabase column field, and others.).
  
  Useful to inform a friendly validation message to User Interface, customized as needed.
  
  ## Example

  ```elixir 
  iex > Krug.ReturnUtil.getValidationResult(100100,"[100100] E-mail should be a valid email.")
  %{
    objectClass: "ValidationResult",
    code: 100100,
    msg: "[100100] E-mail should be a valid email."
  }
  ```
  """
  def getValidationResult(codeReturn,msgResult) do
    %{
      objectClass: "ValidationResult",
      code: codeReturn,
      msg: msgResult
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
  iex > Krug.ReturnUtil.getReport(html)
  [
    %{
      objectClass: "Report",
      code: 205,
      msg: "<h1>This is the Report Header of Generated Report</h1>"
    }
  ]
  ```
  """
  def getReport(html) do
    [%{
      objectClass: "Report",
      code: 205,
      msg: html
    }]
  end
  


end