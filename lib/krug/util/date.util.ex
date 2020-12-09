defmodule Krug.DateUtil do

  @moduledoc """
  Utilitary module to handle date and datetime conversions.
  """

  alias Krug.StringUtil
  alias Krug.NumberUtil


  
  @doc """
  Convert a numeric timestamp value in miliseconds to a sql date string in format yyyy-mm-dd H:i:s.
  
  If receive a nil or <= 0 value, return nil.

  ## Example

  ```elixir 
  iex > timestamp = 2709876599456
  iex > Krug.DateUtil.timeToSqlDate(timestamp)
  2055-11-15 07:29:59
  ```
  """
  def timeToSqlDate(timestamp) do
    cond do
      (nil == timestamp or !(timestamp > 0)) -> nil
      true -> DateTime.from_unix(timestamp, :millisecond) 
                |> Tuple.to_list() 
                |> Enum.at(1) 
                |> DateTime.to_string()
                |> String.slice(0..18)
    end
  end


  
  @doc """
  Obtain the actual date in format yyyy-mm-dd.
  
  Return a Elixir Date Object.

  ## Example

  ```elixir 
  iex > Krug.DateUtil.getNow()
  ~D[2020-12-05]
  ```
  """
  def getNow() do
    Date.utc_today()
  end
  
  

  @doc """
  Obtain the actual date as string in format dd/mm/yyyy.
  
  ## Example

  ```elixir 
  iex > Krug.DateUtil.getDateNowString()
  05/12/2020
  ```
  """  
  def getDateNowString() do
    now = getNow()
    Enum.join([StringUtil.leftZeros(now.day,2),
               StringUtil.leftZeros(now.month,2),
               StringUtil.leftZeros(now.year,4)],"/")
  end
  
  
  
  @doc """
  Obtain the actual hour of day as string in format H:i:s.
  
  ## Example

  ```elixir 
  iex > Krug.DateUtil.getTimeNowString()
  17:35:58
  ```
  """  
  def getTimeNowString() do
  	time = Time.utc_now()
  	Enum.join([StringUtil.leftZeros(time.hour,2),
  	           StringUtil.leftZeros(time.minute,2),
  	           StringUtil.leftZeros(time.second,2)],":")
  end
  
  
  
  @doc """
  Obtain the actual datetime in numeric milliseconds.
  
  ## Example

  ```elixir 
  iex > Krug.DateUtil.getDateTimeNowMillis()
  1607193124063
  ```
  """  
  def getDateTimeNowMillis() do
    :os.system_time(:millisecond)
  end
  
  
  
  @doc """
  Obtain the actual date and time as string in format dd/mm/yyyy H:i:s.
  
  ## Example

  ```elixir 
  iex > Krug.DateUtil.getDateAndTimeNowString()
  05/12/2020 17:35:58
  ```
  """  
  def getDateAndTimeNowString() do
    Enum.join([getDateNowString(),getTimeNowString()]," ")
  end


  
  @doc """
  Obtain the actual date and time as string in format yyyy-mm-dd H:i:s, making
  some operations according received parameters.
  
  If diffDays > 0, add this number of days in date (date + diffDays).
  
  If diffDays < 0, subtract this number in date (date - diffDays).
  
  If beginDay == true, set time to 00:00:00, otherwise if endDay == true
  set time to 23:59:59.
  
  ## Examples

  ```elixir 
  iex > Krug.DateUtil.getNowToSql(0,false,false)
  2020-12-05 17:35:58
  ```
  ```elixir 
  iex > Krug.DateUtil.getNowToSql(1,false,false)
  2020-12-06 17:35:58
  ```
  ```elixir 
  iex > Krug.DateUtil.getNowToSql(-1,false,false)
  2020-12-04 17:35:58
  ```
  ```elixir 
  iex > Krug.DateUtil.getNowToSql(0,true,false)
  2020-12-05 00:00:00
  ```
  ```elixir 
  iex > Krug.DateUtil.getNowToSql(0,false,true)
  2020-12-05 23:59:59
  ```
  ```elixir 
  iex > Krug.DateUtil.getNowToSql(3,true,false)
  2020-12-08 00:00:00
  ```
  """  
  def getNowToSql(diffDays,beginDay,endDay) do
    date = getNow()
    cond do
      (nil != diffDays && diffDays != 0) -> getNowToSqlInternal(Date.add(date,diffDays),beginDay,endDay)
      true -> getNowToSqlInternal(date,beginDay,endDay)
    end
  end
  
  
  
  @doc """
  Obtain one date and time as string in format yyyy-mm-dd or yyyy-mm-dd H:i:s 
  
  and convert to format dd/mm/yyyy H:i:s or dd/mm/yyyy 
  
  conform the value and parameter received.
  
  ## Examples

  ```elixir 
  iex > Krug.DateUtil.sqlDateToTime("2020-12-05 17:35:58")
  05/12/2020 17:35:58
  ```
  ```elixir 
  iex > Krug.DateUtil.sqlDateToTime("2020-12-05 17:35:58",false)
  05/12/2020
  ```
  ```elixir 
  iex > Krug.DateUtil.sqlDateToTime("2020-12-05")
  05/12/2020
  ```
  """  
  def sqlDateToTime(sqlDate,whitTime \\ true) do
    arr = sqlDate |> StringUtil.split(" ")
    arr2 = arr |> Enum.at(0) |> StringUtil.split("-")
    cond do
      (!(Enum.member?([10,19],String.length(sqlDate)))) -> nil
      (whitTime == true and length(arr) > 1) 
        -> "#{Enum.at(arr2,2)}/#{Enum.at(arr2,1)}/#{Enum.at(arr2,0)} #{Enum.at(arr,1) |> String.slice(0,8)}"
      true -> "#{Enum.at(arr2,2)}/#{Enum.at(arr2,1)}/#{Enum.at(arr2,0)}"
    end
  end
  
  
  
  @doc """
  Calculates the diff in seconds between 2 date and time as string in format yyyy-mm-dd H:i:s.
  
  ## Examples

  ```elixir 
  iex > Krug.DateUtil.diffSqlDatesInSeconds("2020-12-05 17:35:58","2020-12-05 16:35:58")
  -3600
  ```
  ```elixir 
  iex > Krug.DateUtil.diffSqlDatesInSeconds("2020-12-05 17:35:58","2020-12-05 18:35:58")
  3600
  ```
  """  
  def diffSqlDatesInSeconds(sqlDateStart,sqlDateFinish) do
    dateStart = sqlDateToDateTime(sqlDateStart)
    dateFinish = sqlDateToDateTime(sqlDateFinish)
    DateTime.diff(dateFinish,dateStart)
  end
  
  
  
  @doc """
  Calculates the atual date minus X minutes in format yyyy-mm-dd H:i:s.
  
  Useful when you need verify if an event run in last minute, 
  for example clear a cache, or count a number 
  of requests of a service since last minute.
  
  ## Example
  
  Imagine that actual date is 2020-12-05 00:00:35.
  
  ```elixir 
  iex > Krug.DateUtil.minusMinutesSql(1)
  2020-12-04 23:59:35
  ```
  """  
  def minusMinutesSql(minutes) do
    now = getDateTimeNowMillis()
    (now - (minutes * 60 * 1000)) |> timeToSqlDate()
  end
  
  
  
  @doc """
  Verify if two nano seconds obtained by ```System.os_time()```
  match in same year. 
  
  Useful if you want controll use of resources by time interval. 
  """  
  def sameYear(nanoseconds1,nanoseconds2) do
    toYears(nanoseconds1) == toYears(nanoseconds2)
  end
  
  
  
  @doc """
  Verify if two nano seconds obtained by ```System.os_time()```
  match in same month of same year. 
  
  Useful if you want controll use of resources by time interval. 
  """  
  def sameMonth(nanoseconds1,nanoseconds2) do
    toMonths(nanoseconds1) == toMonths(nanoseconds2)
  end
  
  
  
  @doc """
  Verify if two nano seconds obtained by ```System.os_time()```
  match in same day of same month of same year. 
  
  Useful if you want controll use of resources by time interval. 
  """  
  def sameDay(nanoseconds1,nanoseconds2) do
    toDays(nanoseconds1) == toDays(nanoseconds2)
  end
  
  
  
  @doc """
  Verify if two nano seconds obtained by ```System.os_time()```
  match in same hour of same day of same month of same year. 
  
  Useful if you want controll use of resources by time interval. 
  """  
  def sameHour(nanoseconds1,nanoseconds2) do
    toHours(nanoseconds1) == toHours(nanoseconds2)
  end
  
  
  
  @doc """
  Verify if two nano seconds obtained by ```System.os_time()```
  match in same minute of same hour of ... of same year. 
  
  Useful if you want controll use of resources by time interval. 
  """  
  def sameMinute(nanoseconds1,nanoseconds2) do
    toMinutes(nanoseconds1) == toMinutes(nanoseconds2)
  end
  
  
  
  @doc """
  Verify if two nano seconds obtained by ```System.os_time()```
  match in same second of same minute of same ... of same year.
   
  Useful if you want controll use of resources by time interval. 
  """  
  def sameSecond(nanoseconds1,nanoseconds2) do
    toSeconds(nanoseconds1) == toSeconds(nanoseconds2)
  end
  
  
  
  defp sqlDateToDateTime(sqlDate) do
    sqlDate = sqlDate |> String.slice(0..18)
    dateArr = sqlDate |> StringUtil.trim() |> StringUtil.split(" ")
    dateArr1 = dateArr |> Enum.at(0) |> StringUtil.split("-")
    dateArr2 = dateArr |> Enum.at(1) |> StringUtil.split(":")
    year = dateArr1 |> Enum.at(0) |> NumberUtil.toInteger()
    month = dateArr1 |> Enum.at(1) |> NumberUtil.toInteger()
    day = dateArr1 |> Enum.at(2) |> NumberUtil.toInteger()
    hour = dateArr2 |> Enum.at(0) |> NumberUtil.toInteger()
    minute = dateArr2 |> Enum.at(1) |> NumberUtil.toInteger()
    second = dateArr1 |> Enum.at(2) |> NumberUtil.toInteger()
    %DateTime{year: year, month: month, day: day,hour: hour, minute: minute, second: second,
              zone_abbr: "GMT", utc_offset: -10800, std_offset: 0, time_zone: "America/Sao Paulo"}
  end
  
  
  
  defp getNowToSqlInternal(date,beginDay,endDay) do
    year = date.year
    month = StringUtil.leftZeros(date.month,2)
    day = StringUtil.leftZeros(date.day,2)
    stringDate = Enum.join([year,month,day],"-")
    cond do
      beginDay ->  Enum.join([stringDate,"00:00:00"]," ")
      endDay ->  Enum.join([stringDate,"23:59:59"]," ")
      true -> Enum.join([stringDate,getTimeNowString()]," ")
    end
  end
  
  
  
  defp toYears(nanoseconds) do
    div(toMonths(nanoseconds),365)
  end
  
  
  
  defp toMonths(nanoseconds) do
    div(toDays(nanoseconds),30)
  end
  
  
  
  defp toDays(nanoseconds) do
    div(toHours(nanoseconds),24)
  end
  
  
  
  defp toHours(nanoseconds) do
    div(toMinutes(nanoseconds),60)
  end
  
  
  
  defp toMinutes(nanoseconds) do
    div(toSeconds(nanoseconds),60)
  end
  
  
  
  defp toSeconds(nanoseconds) do
    div(nanoseconds,1000000000)
  end
  
  
  
end