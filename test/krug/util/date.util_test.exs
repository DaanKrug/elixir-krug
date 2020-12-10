defmodule Krug.DateUtilTest do
  use ExUnit.Case
  
  doctest Krug.DateUtil
  
  alias Krug.DateUtil
  alias Krug.StringUtil 
  
  test "[time_to_sql_date(timestamp)]" do
    assert DateUtil.time_to_sql_date(1309876543456) == "2011-07-05 14:35:43"
    assert DateUtil.time_to_sql_date(1409876543456) == "2014-09-05 00:22:23"
    assert DateUtil.time_to_sql_date(1509876543456) == "2017-11-05 10:09:03"
    assert DateUtil.time_to_sql_date(1609876543456) == "2021-01-05 19:55:43"
    assert DateUtil.time_to_sql_date(1709876543456) == "2024-03-08 05:42:23"
    assert DateUtil.time_to_sql_date(1809876543456) == "2027-05-09 15:29:03"
    assert DateUtil.time_to_sql_date(1909876543456) == "2030-07-10 01:15:43"
    assert DateUtil.time_to_sql_date(2009876543456) == "2033-09-09 11:02:23"
    assert DateUtil.time_to_sql_date(2709876599456) == "2055-11-15 07:29:59"
  end
  
  test "[get_now()]" do
    datetime = DateTime.now("Etc/UTC") |> Tuple.to_list() |> Enum.at(1)
    now = DateUtil.get_now()
    assert StringUtil.left_zeros(now.day,2) == StringUtil.left_zeros(datetime.day,2)
    assert StringUtil.left_zeros(now.month,2) == StringUtil.left_zeros(datetime.month,2)
    assert StringUtil.left_zeros(now.year,4) == StringUtil.left_zeros(datetime.year,4)
  end
  
  test "[get_date_now_string()]" do
    datetime = DateTime.now("Etc/UTC") |> Tuple.to_list() |> Enum.at(1)
    array = DateUtil.get_date_now_string() |> StringUtil.split("/")
    assert StringUtil.left_zeros(datetime.day,2) == Enum.at(array,0)
    assert StringUtil.left_zeros(datetime.month,2) == Enum.at(array,1)
    assert StringUtil.left_zeros(datetime.year,4) == Enum.at(array,2)
  end
  
  test "[get_time_now_string()]" do
    datetime = DateTime.now("Etc/UTC") |> Tuple.to_list() |> Enum.at(1)
    array = DateUtil.get_time_now_string() |> StringUtil.split(":")
    assert StringUtil.left_zeros(datetime.hour,2) == Enum.at(array,0)
    assert StringUtil.left_zeros(datetime.minute,2) == Enum.at(array,1)
    assert StringUtil.left_zeros(datetime.second,2) == Enum.at(array,2)
  end
  
  test "[get_date_time_now_millis()]" do
    assert DateUtil.get_date_time_now_millis() > 1509876543456
    assert DateUtil.get_date_time_now_millis() < 2709876599456
  end 
  
  test "[get_date_and_time_now_string()]" do
    nowArray = DateUtil.get_date_and_time_now_string() |> StringUtil.split(" ")
    datetime = DateTime.now("Etc/UTC") |> Tuple.to_list() |> Enum.at(1)
    array = nowArray |> Enum.at(0) |> StringUtil.split("/")
    assert StringUtil.left_zeros(datetime.day,2) == Enum.at(array,0)
    assert StringUtil.left_zeros(datetime.month,2) == Enum.at(array,1)
    assert StringUtil.left_zeros(datetime.year,4) == Enum.at(array,2)
    array = nowArray |> Enum.at(1) |> StringUtil.split(":")
    assert StringUtil.left_zeros(datetime.hour,2) == Enum.at(array,0)
    assert StringUtil.left_zeros(datetime.minute,2) == Enum.at(array,1)
    assert StringUtil.left_zeros(datetime.second,2) == Enum.at(array,2)
  end
  
  test "[sql_date_to_time(sql_date,with_time \\ true)]" do
    assert DateUtil.sql_date_to_time("2020-12-05 17:35:58") == "05/12/2020 17:35:58"
    assert DateUtil.sql_date_to_time("2020-12-05 17:35:58",false) == "05/12/2020"
    assert DateUtil.sql_date_to_time("2020-12-05") == "05/12/2020"
    assert DateUtil.sql_date_to_time("2020-12-05 ") == nil
    assert DateUtil.sql_date_to_time("2020-12-05 17:35:5") == nil
    assert DateUtil.sql_date_to_time("2020-12-0") == nil
  end
  
  test "[diff_sql_dates_in_seconds(sql_date_start,sql_date_finish)]" do
    assert DateUtil.diff_sql_dates_in_seconds("2020-12-05 17:35:58","2020-12-05 16:35:58") == -3600
    assert DateUtil.diff_sql_dates_in_seconds("2020-12-05 17:35:58","2020-12-05 18:35:58") == 3600
  end
  
  test "[minus_minutes_sql(1)]" do
    now = DateUtil.get_date_time_now_millis()
    nowMinusOne = now - 60000
    assert DateUtil.minus_minutes_sql(1) == DateUtil.time_to_sql_date(nowMinusOne)
    nowMinusOne = now - (150 * 60000)
    assert DateUtil.minus_minutes_sql(150) == DateUtil.time_to_sql_date(nowMinusOne)
  end
  
end









