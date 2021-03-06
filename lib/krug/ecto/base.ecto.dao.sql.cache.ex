defmodule Krug.BaseEctoDAOSqlCache do

  @moduledoc false
  
  alias Krug.StringUtil
  alias Krug.MapUtil
  alias Krug.EtsUtil
  alias Krug.DateUtil
  
  
  def extract_table_name(sql) do
    sql = sql |> StringUtil.trim() |> StringUtil.replace("("," ") |> StringUtil.replace("  "," ")
	split_string = cond do
	  (sql |> String.contains?("insert into ")) -> "insert into "
	  (sql |> String.contains?("update ")) -> "update "
	  true -> " from "
	end
	sql |> StringUtil.split(split_string) |> Enum.at(1) |> StringUtil.split(" ") |> Enum.at(0)
  end    

  def load_from_cache(sql,params) do
	EtsUtil.new(:krug_base_ecto_dao_sql_tables_cache,"public")
    EtsUtil.read_from_cache(:krug_sql_tables_cache,extract_table_name(sql))
      |> extract_key_par_list(sql,params)
  end
  
  def put_cache(sql,params,resultset) do
	EtsUtil.new(:krug_base_ecto_dao_sql_tables_cache,"public")
	table = extract_table_name(sql)
	list_new = EtsUtil.read_from_cache(:krug_base_ecto_dao_sql_tables_cache,table)
	             |> replace_key_par_in_list(sql,params,resultset,0)
	EtsUtil.store_in_cache(:krug_base_ecto_dao_sql_tables_cache,table,list_new)
	resultset
  end
  	  
  def clear_cache(sql) do
    EtsUtil.new(:krug_base_ecto_dao_sql_tables_cache,"public")
	EtsUtil.remove_from_cache(:krug_base_ecto_dao_sql_tables_cache,extract_table_name(sql))
  end
  
  defp replace_key_par_in_list(list,sql,params,resultset,counter) do
    cond do
      (nil == list or counter >= length(list)) 
        -> append_new_resultset_params_in_list(list,sql,params,resultset)
      (list |> Enum.at(counter) |> MapUtil.get(:sql) != sql) 
        -> replace_key_par_in_list(list,sql,params,resultset,counter + 1)
      (list |> Enum.at(counter) |> MapUtil.get(:params) != params) 
        -> replace_key_par_in_list(list,sql,params,resultset,counter + 1)
      true -> replace_resultset_at_list(list,counter,resultset)
    end
  end
  
  defp replace_resultset_at_list(list,position,resultset) do
    map = list |> Enum.at(position) |> MapUtil.replace(:resultset,resultset)
    map = map |> MapUtil.replace(:lastusedtime,DateUtil.get_date_time_now_millis())
    List.replace_at(list,position,map)
  end
	
  defp extract_key_par_list(list,sql,params) do
    cond do
      (nil == list or length(list) == 0) -> nil
      (list |> hd() |> MapUtil.get(:sql) == sql 
         and list |> hd() |> MapUtil.get(:params) == params) 
        -> list |> hd() |> MapUtil.get(:resultset)
      true -> extract_key_par_list(list |> tl(),sql,params)
    end
  end
  
  defp append_new_resultset_params_in_list(list,sql,params,resultset) do
    map = %{
      sql: sql, 
      params: params, 
      resultset: resultset, 
      lastusedtime: DateUtil.get_date_time_now_millis()
    }
    cond do
      (nil == list or length(list) == 0) -> [map]
      true -> [map | list] |> remove_old_cache_results()
    end
  end
  
  defp remove_old_cache_results(list) do
    cond do
      (length(list) < 10) -> list
      true -> Enum.sort(list, &(&1.lastusedtime > &2.lastusedtime))
                |> Enum.slice(0,10)
    end
  end
	  
end

