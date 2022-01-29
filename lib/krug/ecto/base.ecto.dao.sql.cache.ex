defmodule Krug.BaseEctoDAOSqlCache do

  @moduledoc false
  
  alias Krug.EtsUtil
  
  
  def load_from_cache(ets_key,normalized_sql,params) do
	obj_key = normalized_sql |> build_key(params)
    EtsUtil.read_from_cache(ets_key,obj_key)
  end
  
  def put_cache(ets_key,normalized_sql,params,resultset,_cache_objects_per_table) do
	obj_key = normalized_sql |> build_key(params)
	EtsUtil.store_in_cache(ets_key,obj_key,resultset)
	resultset
  end
  	  
  def clear_cache(ets_key) do
    ets_key |> EtsUtil.delete()
  end
  
  defp build_key(normalized_sql,params) do
    [normalized_sql,"_",params |> Poison.encode() |> elem(1)] |> IO.iodata_to_binary()
  end
  
end

