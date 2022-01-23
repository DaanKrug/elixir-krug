defmodule Krug.BaseEctoDAOUtil do

  @moduledoc false
  
  alias Krug.StringUtil
  
  
  def normalize_sql(sql) do
    sql 
	  |> StringUtil.trim() 
	  |> StringUtil.replace("\r\n"," ")
	  |> StringUtil.replace("\n"," ")
	  |> StringUtil.replace("  "," ")
  end
  
  def extract_table_name(normalized_sql) do
	split_string = normalized_sql |> extract_split_string()
	normalized_sql 
	  |> StringUtil.replace("("," ") 
	  |> StringUtil.split(split_string) 
	  |> Enum.at(1) 
	  |> StringUtil.split(" ") 
	  |> Enum.at(0)
  end   
  
  defp extract_split_string(normalized_sql) do 
    cond do
	  (normalized_sql |> String.starts_with?("insert into ")) -> "insert into "
	  (normalized_sql |> String.starts_with?("update ")) -> "update "
	  true -> " from "
	end
  end 
  
end