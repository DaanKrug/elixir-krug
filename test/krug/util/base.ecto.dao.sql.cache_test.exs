defmodule Krug.BaseEctoDAOSqlCacheTest do
  use ExUnit.Case
  
  doctest Krug.BaseEctoDAOSqlCache
  
  alias Krug.BaseEctoDAOSqlCache
  
  test "[extract_table_name(sql)]" do
    table = "my_table"
    sql = "insert into my_table(a1,a2"
    sql2 = "insert into my_table (a1,a2"
    sql3 = "insert into my_table( a1,a2"
    sql4 = "update my_table set a1 = ?"
    sql5 = "delete   from  my_table  where"
    sql6 = "select a1, a2, a3  from  my_table  where"
    assert BaseEctoDAOSqlCache.extract_table_name(sql) == table
    assert BaseEctoDAOSqlCache.extract_table_name(sql2) == table
    assert BaseEctoDAOSqlCache.extract_table_name(sql3) == table
    assert BaseEctoDAOSqlCache.extract_table_name(sql4) == table
    assert BaseEctoDAOSqlCache.extract_table_name(sql5) == table
    assert BaseEctoDAOSqlCache.extract_table_name(sql6) == table
  end
  
end