defmodule Krug.ResultSetHandler do

  @moduledoc """
  Module to handle the resultset returned by ```Krug.BaseEctoDAO``` (extended modules) load function.
  """
  @moduledoc since: "0.2.0"

  alias Krug.StringUtil
  
  
  
  @doc """
  Concat the value of column ```col``` of all rows of resultset.
  Return a string with values delimited with comma char.
  
  - Supose that was load a result as follow:
  ```elixir
  %MyXQL.Result{
    columns: ["id", "name", "email", "age", "address"],
    connection_id: 1515,
    last_insert_id: 0,
    num_rows: 1,
    num_warnings: 0,
    rows: [
      [1,"Johannes Backend","johannes@backend.com",54,"404 street"],
      [2,"Peter Druggking","peter@thedrugger.com",23,"404 street"],
      [3,"Josephine Frontfull","josephine@staline.com",34,"404 street"]
    ]
  }
  ```
  
  ```elixir 
  iex > Krug.ResultSetHandler.concat_cols_of_result_rows(resultset,0)
  "1,2,3"
  ```
  ```elixir 
  iex > Krug.ResultSetHandler.concat_cols_of_result_rows(resultset,1)
  "Johannes Backend,Peter Druggking,Josephine Frontfull"
  ```
  ```elixir 
  iex > Krug.ResultSetHandler.concat_cols_of_result_rows(resultset,2)
  "johannes@backend.com,peter@thedrugger.com,josephine@staline.com"
  ```
  ```elixir 
  iex > Krug.ResultSetHandler.concat_cols_of_result_rows(resultset,3)
  "54,23,34"
  ```
  """
  def concat_cols_of_result_rows(resultset,col) do 
    get_column_values_concat("",resultset,0,col)
  end
  
   
  
  @doc """
  Obtain the value of a column ```col``` of a row ```row``` of resultset.
  
  Return a empty string if value is nil.
  
  - Supose that was load a result as follow:
  ```elixir
  %MyXQL.Result{
    columns: ["id", "name", "email", "age", "popularitypercent", "address"],
    connection_id: 1515,
    last_insert_id: 0,
    num_rows: 1,
    num_warnings: 0,
    rows: [
      [1,"Johannes Backend","johannes@backend.com",54,95.7,"404 street"],
      [2,"Peter Druggking","peter@thedrugger.com",23,66.6,"404 street"],
      [3,"Josephine Frontfull","josephine@staline.com",34,17.3,"404 street"]
    ]
  }
  ```
  
  And you want transform it to a pretty map array as [%{},%{},%{}], then
  you could iterate recursively the resultset, making some as this for each row:
  ```elixir
  %{
    id: Krug.ResultSetHandler.get_column_value(resultset,row,0) |> Krug.NumberUtil.to_integer(),
    name: Krug.ResultSetHandler.get_column_value(resultset,row,1),
    email: Krug.ResultSetHandler.get_column_value(resultset,row,2),
    age: Krug.ResultSetHandler.get_column_value(resultset,row,3) |> Krug.NumberUtil.to_integer(),
    popularitypercent: Krug.ResultSetHandler.get_column_value(resultset,row,4) |> Krug.NumberUtil.to_float(),
    address: Krug.ResultSetHandler.get_column_value(resultset,row,5)
  }
  ```  
  """
  def get_column_value(resultset,row,col) do
    array_data = get_row_as_array(resultset,row)
    value = cond do
      (nil == array_data or length(array_data) == 0) -> "" 
      (nil == col or !(col >= 0) or col >= length(array_data)) -> "" 
      true -> array_data |> Enum.at(col)
    end
  	"#{value}"
  end
  
  
  
  defp get_row_as_array(resultset,row) do
  	cond do
  	  (nil == resultset or nil == resultset.rows) -> nil
  	  (nil == row or !(row >= 0)) -> nil 
  	  (nil == resultset.rows or length(resultset.rows) == 0) -> nil
  	  (row >= length(resultset.rows)) -> nil
  	  true -> resultset.rows |> Enum.at(row)
  	end
  end
  
  
  
  defp get_column_values_concat(string,resultset,row,col) do
    value = get_column_value_use_nil(resultset,row,col)
    cond do
      (nil == value) -> string |> get_column_values_concat(resultset,row + 1,col)
      true -> string |> StringUtil.concat(value,",") |> get_column_values_concat(resultset,row + 1,col)
    end
  end
  
  
  
  defp get_column_value_use_nil(resultset,row,col) do
    array_data = get_row_as_array(resultset,row)
    cond do
      (nil == array_data or length(array_data) == 0) -> nil
      (nil == col or !(col >= 0) or col >= length(array_data)) -> nil
      true -> array_data |> Enum.at(col)
    end
  end
  
  
  
end