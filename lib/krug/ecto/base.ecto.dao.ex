defmodule Krug.BaseEctoDAO do

  @moduledoc """
  Defines a behaviour for higher-level CRUD functionalities module
  to facilitate the raw queries usage with Ecto.
  
  Utilization: Create a module that extends ```Krug.BaseEctoDAO```.
  - ```MyApp.App.Repo``` should be a module that extends Ecto.Repo. (Required)
  - ```ets_key```should be an atom thats identifier the ETS table for caching. (Required)
    This should be created in Ecto repository initialization, inside the init/2 function,
    call Krug.EtsUtil.new(:my_ets_key_atom_identifier)
  
  ```elixir
  defmodule MyApp.App.Repo do 
    
    use Ecto.Repo, otp_app: :my_app, adapter: Ecto.Adapters.MyXQL
    ...
    alias Krug.EtsUtil
    
    def init(_type, config) do
      ...
      EtsUtil.new(:my_ets_key_atom_identifier)
      {:ok, config}
    end
  
  end
  
  
  defmodule MyApp.App.DAOService do

    use Krug.BaseEctoDAO, repo: MyApp.App.Repo, ets_key: :my_ets_key_atom_identifier

  end
  ```
  
  This mechanism also includes by default a in-memory query cache
  of last ```cache_objects_per_table``` (default to 10) select results of each database table.
  This cache (for respective table) is empty each time that a entry 
  is inserted/updated/deleted from the respective table.
  You can disable this mechanism for expensive tables (large text data or many columns), 
  or tables that are very intensible/frequently writed/updated.
  For this use the ```nocache_tables``` atribute.
  
  ```elixir
  defmodule MyApp.App.DAOService do

    use Krug.BaseEctoDAO, 
      repo: MyApp.App.Repo, 
      nocache_tables: ["my_table_no_cache1","my_table_no_cache2"], 
      cache_objects_per_table: 10,
      ets_key: :my_ets_key_atom_identifier

  end
  ```
  """
  @moduledoc since: "0.2.0"
  
  
  @doc """
  Return the ets_key (```:my_ets_key_atom_identifier```) value 
  to be used whit other database services
  to handle other cache storage functionalities, for example store
  processed list objects relative to a SQL search in place of store
  the brute database resultset.
  
  ```elixir 
  Krug.EtsUtil.store_in_cache(ets_key,obj_key,obj_value)
  BaseEctoDAOSqlCache.put_cache(ets_key,table_name,normalized_sql,params,resultset,cache_objects_per_table)
  
  cache_result = Krug.EtsUtil.load_from_cache(ets_key,key)
  cache_result = Krug.BaseEctoDAOSqlCache.load_from_cache(ets_key,table_name,normalized_sql,params)
  
  Krug.EtsUtil.remove_from_cache(ets_key,obj_key)
  
  
  ```
  """
  @doc since: "1.0.2"
  @callback get_ets_key() :: atom
  
  
  
  @doc """
  Return the ets_key (```:cache_objects_per_table```) value 
  to be used whit other database services
  to handle other cache storage functionalities, for example store
  processed list objects relative to a SQL search in place of store
  the brute database resultset.
  
  ```elixir 
  BaseEctoDAOSqlCache.put_cache(ets_key,table_name,normalized_sql,params,resultset,cache_objects_per_table)
  ```
  """
  @doc since: "1.0.3"
  @callback get_cache_objects_per_table() :: number
  
  
  
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
    
      alias Krug.BaseEctoDAOSqlCache
      alias Krug.BaseEctoDAOUtil
      
      alias Krug.StringUtil
    
      @behaviour Krug.BaseEctoDAO
     
      @repo Keyword.get(opts,:repo)
      @nocache_tables Keyword.get(opts,:nocache_tables)
      @cache_objects_per_table Keyword.get(opts,:cache_objects_per_table)
      @ets_key Keyword.get(opts,:ets_key)
      
      @impl Krug.BaseEctoDAO
      def get_ets_key() do
        @ets_key
      end
      
      @impl Krug.BaseEctoDAO
      def get_cache_objects_per_table() do
        cond do
          (nil == @cache_objects_per_table or !(@cache_objects_per_table > 0)) -> 10
          true -> @cache_objects_per_table
        end
      end
    
      @impl Krug.BaseEctoDAO
      def load(sql,params \\[]) do
        normalized_sql = sql |> BaseEctoDAOUtil.normalize_sql()
        table_name = normalized_sql |> BaseEctoDAOUtil.extract_table_name()
	    cond do
	      (table_name |> use_cache()) 
	        -> load_with_cache(table_name,normalized_sql,params)
	      true -> load_without_cache(normalized_sql,params)
	    end
	  end
	  
	  @impl Krug.BaseEctoDAO
	  def insert(sql,params) do
	    cud_operation(sql,params)
	  end
	  
	  @impl Krug.BaseEctoDAO
	  def update(sql,params) do
	    cud_operation(sql,params)
	  end
	  
	  @impl Krug.BaseEctoDAO
	  def delete(sql,params) do
	    cud_operation(sql,params)
	  end
	  
	  defp cud_operation(sql,params) do
	    normalized_sql = sql |> BaseEctoDAOUtil.normalize_sql()
	    table_name = normalized_sql |> BaseEctoDAOUtil.extract_table_name()
	  	ok = normalized_sql |> execute_sql(params,true)
	  	cond do
	  	  (!ok) -> ok
	  	  (table_name |> use_cache()) 
	  	    -> BaseEctoDAOSqlCache.clear_cache(@ets_key,table_name)
	  	  true -> ok
	  	end
	  end
	  
	  defp load_without_cache(normalized_sql,params \\[]) do
        execute_sql(normalized_sql,params,false)
	  end
	  
	  defp load_with_cache(table_name,normalized_sql,params \\[]) do
        resultset = BaseEctoDAOSqlCache.load_from_cache(@ets_key,table_name,normalized_sql,params)
	    cond do
	      (nil != resultset) -> resultset
	      true -> load_and_put_to_cache(table_name,normalized_sql,params)
	    end
	  end
	  
	  defp load_and_put_to_cache(table_name,normalized_sql,params) do
        resultset = execute_sql(normalized_sql,params,false)
        cond do
	      (nil != resultset) 
	        -> BaseEctoDAOSqlCache.put_cache(@ets_key,table_name,normalized_sql,
	                                         params,resultset,get_cache_size())
	      true -> nil
	    end
	  end
	  
	  defp get_cache_size() do
	    cond do
	      (nil == @cache_objects_per_table or !(@cache_objects_per_table > 0)) -> 10
	      true -> @cache_objects_per_table
	    end
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
	  
	  defp use_cache(table_name) do
	    cond do
	      (nil == @nocache_tables or Enum.empty?(@nocache_tables)) -> true
	      (Enum.member?(@nocache_tables,table_name)) -> false
	      true -> true
	    end
	  end
	     
    end

  end
  
end
