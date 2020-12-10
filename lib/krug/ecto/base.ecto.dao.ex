defmodule Krug.BaseEctoDAO do

  @moduledoc """
  Defines a behaviour for higher-level CRUD functionalities module
  to facilitate the raw queries usage with Ecto.
  
  Utilization: Create a module that extends ```Krug.BaseEctoDAO```.
  - ```MyApp.App.Repo``` should be a module that extends Ecto.Repo.
  
  ```elixir
  defmodule MyApp.App.DAOService do

    use Krug.BaseEctoDAO, repo: MyApp.App.Repo

  end
  ```
  """
  @moduledoc since: "0.2.0"
  
  
  
  @doc """
  Load a resultset from a table. Return nil only if fail in execution of SQL command.
  
  To see how handle returned resultset, search by ```Krug.ResultSetHandler``` 
  in this documentation.

  ## Examples
  
  ```elixir 
  iex > sql = "select id, name, email, age, address from person limit 10"
  iex > MyApp.App.DAOService.load(sql)
  %MyXQL.Result{
    columns: ["id", "name", "email", "age", "address"],
    connection_id: 1515,
    last_insert_id: 0,
    num_rows: 1,
    num_warnings: 0,
    rows: [
      [1,"Johannes Backend","johannes@backend.com",54,"404 street"]
    ]
  }
  ```
  ```elixir 
  iex > sql = "select id, columnThatNonExists, email, age, address from person limit 10"
  iex > MyApp.App.DAOService.load(sql)
  nil
  ```
  """
  @callback load(sql :: String.t()) :: map
  
  
  
  @doc """
  Load a resultset from a table. Return nil only if fail in execution of SQL command.
  
  To see how handle returned resultset, search by ```Krug.ResultSetHandler``` 
  in this documentation.

  ## Examples

  ```elixir 
  iex > sql = "select id, name, email, age, address from person where age < ?"
  iex > MyApp.App.DAOService.load(sql,[20])
  %MyXQL.Result{
    columns: ["id", "name", "email", "age", "address"],
    connection_id: 1515,
    last_insert_id: 0,
    num_rows: 0,
    num_warnings: 0,
    rows: nil
  }
  ```
  ```elixir 
  iex > sql = "select id, columnThatNotExists, email, age, address from person where age < ?"
  iex > MyApp.App.DAOService.load(sql,[20])
  nil
  ```
  """
  @callback load(sql :: String.t(),params :: Enum.t()) :: map
  
  
  
  @doc """
  Insert a new row on a table.  Return false only if fail in execution of SQL command.

  ## Examples

  ```elixir 
  iex > sql = "insert into person(name,email,age,address) values (?,?,?,?)"
  iex > MyApp.App.DAOService.insert(sql,["Johannes Backend 2"])
  false
  ```
  ```elixir 
  iex > sql = "insert into person(name,email,age,address) values (?,?,?,?)"
  iex > MyApp.App.DAOService.insert(sql,["Johannes Backend 2","johannes@backend.com",54,"404 street"])
  true
  ```
  """
  @callback insert(sql :: String.t(),params :: Enum.t()) :: boolean
  
  
  
  @doc """
  Update a row on a table. Return false only if fail in execution of SQL command.

  ## Examples

  ```elixir 
  iex > sql = "update person set name = ?, email = ? where id = ?"
  iex > MyApp.App.DAOService.update(sql,["Johannes Backend 3","johannes@has.not.email",1])
  true
  ```
  ```elixir 
  iex > sql = "update person set columnThatNotExists = ?, email = ? where id = ?"
  iex > MyApp.App.DAOService.update(sql,["Johannes Backend 3","johannes@has.not.email",1])
  false
  ```
  """
  @callback update(sql :: String.t(),params :: Enum.t()) :: boolean
  
  
  
  @doc """
  Delete a row from a table. Return false only if fail in execution of SQL command.

  ## Examples

  ```elixir 
  iex > sql = "delete from person where name = ? and id = ?"
  iex > MyApp.App.DAOService.delete(sql,["Person Name That Not Exist",1000000000000001])
  true
  ```
  ```elixir 
  iex > sql = "delete from person where columnThatNotExists = ?"
  iex > MyApp.App.DAOService.delete(sql,["Johannes Backend 3"])
  false
  ```
  """
  @callback delete(sql :: String.t(),params :: Enum.t()) :: boolean
  
  
  
  defmacro __using__(opts) do
  
    quote bind_quoted: [opts: opts] do
    
      @behaviour Krug.BaseEctoDAO
     
      @repo Keyword.get(opts,:repo)
    
      @impl Krug.BaseEctoDAO
      def load(sql,params \\[]) do
	    execute_sql(sql,params,false)
	  end
	  
	  @impl Krug.BaseEctoDAO
	  def insert(sql,params) do
	  	execute_sql(sql,params,true)
	  end
	  
	  @impl Krug.BaseEctoDAO
	  def update(sql,params) do
	  	execute_sql(sql,params,true)
	  end
	  
	  @impl Krug.BaseEctoDAO
	  def delete(sql,params) do
	  	execute_sql(sql,params,true)
	  end
	  
	  defp execute_sql(sql,params,bool_result) do
	  	Ecto.Adapters.SQL.query(@repo,sql,params) |> handle_query_result(bool_result)
	  end
	  
	  defp handle_query_result({:ok, result},bool_result) do
	    cond do
	      (bool_result) -> true
	      true -> result
	    end
	  end
	  
	  defp handle_query_result({:error, _reason},bool_result) do
	    cond do
	      (bool_result) -> false
	      true -> nil
	    end
	  end     
    
    end

  end
  
end