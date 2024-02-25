defmodule Krug.BaseEctoDAOUtil do

  @moduledoc false
  
  alias Krug.StringUtil
  
  
  def normalize_sql(sql) do
    sql 
	  |> StringUtil.trim(true) 
	  |> StringUtil.replace("\r\n"," ",true)
	  |> StringUtil.replace("\n"," ",true)
	  |> StringUtil.replace("  "," ",true)
  end
  
  def extract_table_name(normalized_sql) do
	split_string = normalized_sql |> extract_split_string()
	normalized_sql 
	  |> StringUtil.replace("("," ",true) 
	  |> StringUtil.split(split_string,true) 
	  |> tl()
	  |> hd()
	  |> StringUtil.split(" ",true) 
	  |> hd()
  end   
  
  defp extract_split_string(normalized_sql) do 
    cond do
	  (normalized_sql |> String.starts_with?("insert into ")) -> "insert into "
	  (normalized_sql |> String.starts_with?("update ")) -> "update "
	  true -> " from "
	end
  end 
  
end