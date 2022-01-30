defmodule Krug.BaseEctoDAOSqlCache do

  @moduledoc false
  
  alias Krug.MapUtil
  alias Krug.EtsUtil
  alias Krug.DateUtil
  
  
  def load_from_cache(ets_key,table_name,normalized_sql,params) do
    EtsUtil.read_from_cache(ets_key,table_name)
      |> extract_key_par_list(normalized_sql,params)
  end
  
  def put_cache(ets_key,table_name,normalized_sql,params,resultset,cache_objects_per_table) do
	list_new = EtsUtil.read_from_cache(ets_key,table_name)
	             |> replace_key_par_in_list(normalized_sql,params,resultset,0,cache_objects_per_table)
	EtsUtil.store_in_cache(ets_key,table_name,list_new)
	resultset
  end
  	  
  def clear_cache(ets_key,table_name) do
	EtsUtil.remove_from_cache(ets_key,table_name)
  end
  
  defp replace_key_par_in_list(list,normalized_sql,params,resultset,counter,cache_objects_per_table) do
    cond do
      (nil == list or Enum.empty?(list)) 
        -> [new_resultset_param_map(normalized_sql,params,resultset)]
      (counter >= length(list)) 
        -> append_resultset_params_in_list(list,normalized_sql,params,resultset,cache_objects_per_table)
      true -> replace_key_par_in_list2(list,normalized_sql,params,resultset,counter,cache_objects_per_table)
    end
  end
  
  defp replace_key_par_in_list2(list,normalized_sql,params,resultset,counter,cache_objects_per_table) do
    cache_result = list |> Enum.at(counter)
    cache_sql = cache_result |> MapUtil.get(:sql)
    cache_params = cache_result |> MapUtil.get(:params)
    cond do
      (cache_sql != normalized_sql or cache_params != params) 
          -> replace_key_par_in_list(list,normalized_sql,params,
                                     resultset,counter + 1,cache_objects_per_table)
      true -> replace_resultset_at_list(list,counter,resultset)
    end
  end
  
  defp replace_resultset_at_list(list,position,resultset) do
    map = list |> Enum.at(position) |> MapUtil.replace(:resultset,resultset)
    map = map |> MapUtil.replace(:lastusedtime,DateUtil.get_date_time_now_millis())
    List.replace_at(list,position,map)
  end
	
  defp extract_key_par_list(list,normalized_sql,params) do
    cond do
      (nil == list) -> nil
      true -> extract_key_par_list2(list,normalized_sql,params)
    end
  end
  
  defp extract_key_par_list2(list,normalized_sql,params) do
    cond do
      (Enum.empty?(list)) -> nil
      true -> extract_key_par_list3(list,normalized_sql,params)
    end
  end
  
  defp extract_key_par_list3(list,normalized_sql,params) do
    map = list |> hd()
    key_par_sql = map |> MapUtil.get(:sql)
    key_par_params = map |> MapUtil.get(:params)
    cond do
      (key_par_sql != normalized_sql or key_par_params != params) 
        -> list |> tl() |> extract_key_par_list2(normalized_sql,params)
      true -> map |> MapUtil.get(:resultset)
    end
  end
  
  defp new_resultset_param_map(normalized_sql,params,resultset) do
    %{
      sql: normalized_sql, 
      params: params, 
      resultset: resultset, 
      lastusedtime: DateUtil.get_date_time_now_millis()
    }
  end
  
  defp append_resultset_params_in_list(list,normalized_sql,params,resultset,cache_objects_per_table) do
    [new_resultset_param_map(normalized_sql,params,resultset) | list] 
      |> remove_old_cache_results(cache_objects_per_table)
  end
  
  defp remove_old_cache_results(list,cache_objects_per_table) do
    cond do
      (length(list) < cache_objects_per_table) -> list
      true -> Enum.sort(list, &(&1.lastusedtime > &2.lastusedtime))
                |> Enum.slice(0,cache_objects_per_table)
    end
  end
	  
end


