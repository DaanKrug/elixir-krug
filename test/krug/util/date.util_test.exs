defmodule Krug.DateUtilTest do
  use ExUnit.Case
  
  doctest Krug.DateUtil
  
  alias Krug.DateUtil
  alias Krug.StringUtil 
  
  test "[timeToSqlDate(timestamp)]" do
    assert DateUtil.timeToSqlDate(1309876543456) == "2011-07-05 14:35:43"
    assert DateUtil.timeToSqlDate(1409876543456) == "2014-09-05 00:22:23"
    assert DateUtil.timeToSqlDate(1509876543456) == "2017-11-05 10:09:03"
    assert DateUtil.timeToSqlDate(1609876543456) == "2021-01-05 19:55:43"
    assert DateUtil.timeToSqlDate(1709876543456) == "2024-03-08 05:42:23"
    assert DateUtil.timeToSqlDate(1809876543456) == "2027-05-09 15:29:03"
    assert DateUtil.timeToSqlDate(1909876543456) == "2030-07-10 01:15:43"
    assert DateUtil.timeToSqlDate(2009876543456) == "2033-09-09 11:02:23"
    assert DateUtil.timeToSqlDate(2709876599456) == "2055-11-15 07:29:59"
  end
  
  test "[getNow()]" do
    datetime = DateTime.now("Etc/UTC") |> Tuple.to_list() |> Enum.at(1)
    now = DateUtil.getNow()
    assert StringUtil.leftZeros(now.day,2) == StringUtil.leftZeros(datetime.day,2)
    assert StringUtil.leftZeros(now.month,2) == StringUtil.leftZeros(datetime.month,2)
    assert StringUtil.leftZeros(now.year,4) == StringUtil.leftZeros(datetime.year,4)
  end
  
  test "[getDateNowString()]" do
    datetime = DateTime.now("Etc/UTC") |> Tuple.to_list() |> Enum.at(1)
    array = DateUtil.getDateNowString() |> StringUtil.split("/")
    assert StringUtil.leftZeros(datetime.day,2) == Enum.at(array,0)
    assert StringUtil.leftZeros(datetime.month,2) == Enum.at(array,1)
    assert StringUtil.leftZeros(datetime.year,4) == Enum.at(array,2)
  end
  
  test "[getTimeNowString()]" do
    datetime = DateTime.now("Etc/UTC") |> Tuple.to_list() |> Enum.at(1)
    array = DateUtil.getTimeNowString() |> StringUtil.split(":")
    assert StringUtil.leftZeros(datetime.hour,2) == Enum.at(array,0)
    assert StringUtil.leftZeros(datetime.minute,2) == Enum.at(array,1)
    assert StringUtil.leftZeros(datetime.second,2) == Enum.at(array,2)
  end
  
  test "[getDateTimeNowMillis()]" do
    assert DateUtil.getDateTimeNowMillis() > 1509876543456
    assert DateUtil.getDateTimeNowMillis() < 2709876599456
  end 
  
  test "[getDateAndTimeNowString()]" do
    nowArray = DateUtil.getDateAndTimeNowString() |> StringUtil.split(" ")
    datetime = DateTime.now("Etc/UTC") |> Tuple.to_list() |> Enum.at(1)
    array = nowArray |> Enum.at(0) |> StringUtil.split("/")
    assert StringUtil.leftZeros(datetime.day,2) == Enum.at(array,0)
    assert StringUtil.leftZeros(datetime.month,2) == Enum.at(array,1)
    assert StringUtil.leftZeros(datetime.year,4) == Enum.at(array,2)
    array = nowArray |> Enum.at(1) |> StringUtil.split(":")
    assert StringUtil.leftZeros(datetime.hour,2) == Enum.at(array,0)
    assert StringUtil.leftZeros(datetime.minute,2) == Enum.at(array,1)
    assert StringUtil.leftZeros(datetime.second,2) == Enum.at(array,2)
  end
  
  test "[sqlDateToTime(sqlDate,whitTime \\ true)]" do
    assert DateUtil.sqlDateToTime("2020-12-05 17:35:58") == "05/12/2020 17:35:58"
    assert DateUtil.sqlDateToTime("2020-12-05 17:35:58",false) == "05/12/2020"
    assert DateUtil.sqlDateToTime("2020-12-05") == "05/12/2020"
    assert DateUtil.sqlDateToTime("2020-12-05 ") == nil
    assert DateUtil.sqlDateToTime("2020-12-05 17:35:5") == nil
    assert DateUtil.sqlDateToTime("2020-12-0") == nil
  end
  
  test "[diffSqlDatesInSeconds(sqlDateStart,sqlDateFinish)]" do
    assert DateUtil.diffSqlDatesInSeconds("2020-12-05 17:35:58","2020-12-05 16:35:58") == -3600
    assert DateUtil.diffSqlDatesInSeconds("2020-12-05 17:35:58","2020-12-05 18:35:58") == 3600
  end
  
  test "[minusMinutesSql(1)]" do
    now = DateUtil.getDateTimeNowMillis()
    nowMinusOne = now - 60000
    assert DateUtil.minusMinutesSql(1) == DateUtil.timeToSqlDate(nowMinusOne)
    nowMinusOne = now - (150 * 60000)
    assert DateUtil.minusMinutesSql(150) == DateUtil.timeToSqlDate(nowMinusOne)
  end
  
end









