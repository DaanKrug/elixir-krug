defmodule Krug.BaseEctoDAOUtilTest do
  use ExUnit.Case
  
  doctest Krug.BaseEctoDAOUtil
  
  alias Krug.BaseEctoDAOUtil
  
  test "[extract_table_name(sql)]" do
    table = "my_table"
    sql = "insert into my_table(a1,a2"
    sql2 = "insert into my_table (a1,a2"
    sql3 = "insert into my_table( a1,a2"
    sql4 = "update my_table set a1 = ?"
    sql5 = "delete   from  my_table  where"
    sql6 = "select a1, a2, a3  from  my_table  where"
    assert sql |> BaseEctoDAOUtil.normalize_sql() |> BaseEctoDAOUtil.extract_table_name() == table
    assert sql2 |> BaseEctoDAOUtil.normalize_sql() |> BaseEctoDAOUtil.extract_table_name() == table
    assert sql3 |> BaseEctoDAOUtil.normalize_sql() |> BaseEctoDAOUtil.extract_table_name() == table
    assert sql4 |> BaseEctoDAOUtil.normalize_sql() |> BaseEctoDAOUtil.extract_table_name() == table
    assert sql5 |> BaseEctoDAOUtil.normalize_sql() |> BaseEctoDAOUtil.extract_table_name() == table
    assert sql6 |> BaseEctoDAOUtil.normalize_sql() |> BaseEctoDAOUtil.extract_table_name() == table
  end
  
end