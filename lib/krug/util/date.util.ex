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
  iex > Krug.DateUtil.time_to_sql_date(timestamp)
  2055-11-15 07:29:59
  ```
  """
  def time_to_sql_date(timestamp) do
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
  iex > Krug.DateUtil.get_now()
  ~D[2020-12-05]
  ```
  """
  def get_now() do
    Date.utc_today()
  end
  
  

  @doc """
  Obtain the actual date as string in format dd/mm/yyyy.
  
  ## Example

  ```elixir 
  iex > Krug.DateUtil.get_date_now_string()
  05/12/2020
  ```
  """  
  def get_date_now_string() do
    now = get_now()
    [StringUtil.left_zeros(now.day,2),"/",StringUtil.left_zeros(now.month,2),"/",StringUtil.left_zeros(now.year,4)] 
      |> IO.iodata_to_binary()
  end
  
  
  
  @doc """
  Obtain the actual hour of day as string in format H:i:s.
  
  ## Example

  ```elixir 
  iex > Krug.DateUtil.get_time_now_string()
  17:35:58
  ```
  """  
  def get_time_now_string() do
  	time = Time.utc_now()
  	[StringUtil.left_zeros(time.hour,2),":",StringUtil.left_zeros(time.minute,2),":",StringUtil.left_zeros(time.second,2)] 
  	  |> IO.iodata_to_binary()
  end
  
  
  
  @doc """
  Obtain the actual datetime in numeric milliseconds.
  
  ## Example

  ```elixir 
  iex > Krug.DateUtil.get_date_time_now_millis()
  1607193124063
  ```
  """  
  def get_date_time_now_millis() do
    :os.system_time(:millisecond)
  end
  
  
  
  @doc """
  Obtain the actual date and time as string in format dd/mm/yyyy H:i:s.
  
  ## Example

  ```elixir 
  iex > Krug.DateUtil.get_date_and_time_now_string()
  05/12/2020 17:35:58
  ```
  """  
  def get_date_and_time_now_string() do
    [get_date_now_string()," ",get_time_now_string()] |> IO.iodata_to_binary()
  end


  
  @doc """
  Obtain the actual date and time as string in format yyyy-mm-dd H:i:s, making
  some operations according received parameters.
  
  If diff_days > 0, add this number of days in date (date + diff_days).
  
  If diff_days < 0, subtract this number in date (date - diff_days).
  
  If begin_day == true, set time to 00:00:00, otherwise if end_day == true
  set time to 23:59:59.
  
  ## Examples

  ```elixir 
  iex > Krug.DateUtil.get_now_to_sql(0,false,false)
  2020-12-05 17:35:58
  ```
  ```elixir 
  iex > Krug.DateUtil.get_now_to_sql(1,false,false)
  2020-12-06 17:35:58
  ```
  ```elixir 
  iex > Krug.DateUtil.get_now_to_sql(-1,false,false)
  2020-12-04 17:35:58
  ```
  ```elixir 
  iex > Krug.DateUtil.get_now_to_sql(0,true,false)
  2020-12-05 00:00:00
  ```
  ```elixir 
  iex > Krug.DateUtil.get_now_to_sql(0,false,true)
  2020-12-05 23:59:59
  ```
  ```elixir 
  iex > Krug.DateUtil.get_now_to_sql(3,true,false)
  2020-12-08 00:00:00
  ```
  """  
  def get_now_to_sql(diff_days,begin_day,end_day) do
    date = get_now()
    cond do
      (diff_days == 0 or nil == diff_days) 
        -> get_now_to_sql_internal(date,begin_day,end_day)
      true -> Date.add(date,diff_days) 
                |> get_now_to_sql_internal(begin_day,end_day)
    end
  end
  
  
  
  @doc """
  Obtain one date and time as string in format yyyy-mm-dd or yyyy-mm-dd H:i:s 
  
  and convert to format dd/mm/yyyy H:i:s or dd/mm/yyyy 
  
  conform the value and parameter received.
  
  ## Examples

  ```elixir 
  iex > Krug.DateUtil.sql_date_to_time("2020-12-05 17:35:58")
  05/12/2020 17:35:58
  ```
  ```elixir 
  iex > Krug.DateUtil.sql_date_to_time("2020-12-05 17:35:58",false)
  05/12/2020
  ```
  ```elixir 
  iex > Krug.DateUtil.sql_date_to_time("2020-12-05")
  05/12/2020
  ```
  """  
  def sql_date_to_time(sql_date,with_time \\ true) do
    arr = sql_date |> StringUtil.split(" ")
    arr2 = arr |> Enum.at(0) |> StringUtil.split("-")
    cond do
      (!(Enum.member?([10,19],String.length(sql_date)))) -> nil
      (with_time == true and length(arr) > 1) 
        -> [Enum.at(arr2,2),"/",Enum.at(arr2,1),"/",Enum.at(arr2,0)," ",Enum.at(arr,1) |> String.slice(0,8)] 
             |> IO.iodata_to_binary()
      true -> [Enum.at(arr2,2),"/",Enum.at(arr2,1),"/",Enum.at(arr2,0)] |> IO.iodata_to_binary() 
    end
  end
  
  
  
  @doc """
  Calculates the diff in seconds between 2 date and time objects as string in format yyyy-mm-dd H:i:s.
  
  ## Examples

  ```elixir 
  iex > Krug.DateUtil.diff_sql_dates_in_seconds("2020-12-05 17:35:58","2020-12-05 16:35:58")
  -3600
  ```
  ```elixir 
  iex > Krug.DateUtil.diff_sql_dates_in_seconds("2020-12-05 17:35:58","2020-12-05 18:35:58")
  3600
  ```
  """  
  def diff_sql_dates_in_seconds(sql_date_start,sql_date_finish) do
    date_start = sql_date_to_date_time(sql_date_start)
    date_finish = sql_date_to_date_time(sql_date_finish)
    DateTime.diff(date_finish,date_start)
  end
  
  
  
  @doc """
  Calculates the atual date minus X minutes in format yyyy-mm-dd H:i:s.
  
  Useful when you need verify if an event run in last minute, 
  for example clear a cache, or count a number 
  of requests of a service since last minute.
  
  ## Example
  
  Imagine that actual date is 2020-12-05 00:00:35.
  
  ```elixir 
  iex > Krug.DateUtil.minus_minutes_sql(1)
  2020-12-04 23:59:35
  ```
  """  
  def minus_minutes_sql(minutes) do
    now = get_date_time_now_millis()
    (now - (minutes * 60 * 1000)) |> time_to_sql_date()
  end
  
  
  
  @doc """
  Verify if two nano seconds obtained by ```System.os_time()```
  match in same year. 
  
  Useful if you want controll use of resources by time interval. 
  """  
  def same_year(nanoseconds1,nanoseconds2) do
    to_years(nanoseconds1) == to_years(nanoseconds2)
  end
  
  
  
  @doc """
  Verify if two nano seconds obtained by ```System.os_time()```
  match in same month of same year. 
  
  Useful if you want controll use of resources by time interval. 
  """  
  def same_month(nanoseconds1,nanoseconds2) do
    to_months(nanoseconds1) == to_months(nanoseconds2)
  end
  
  
  
  @doc """
  Verify if two nano seconds obtained by ```System.os_time()```
  match in same day of same month of same year. 
  
  Useful if you want controll use of resources by time interval. 
  """  
  def same_day(nanoseconds1,nanoseconds2) do
    to_days(nanoseconds1) == to_days(nanoseconds2)
  end
  
  
  
  @doc """
  Verify if two nano seconds obtained by ```System.os_time()```
  match in same hour of same day of same month of same year. 
  
  Useful if you want controll use of resources by time interval. 
  """  
  def same_hour(nanoseconds1,nanoseconds2) do
    to_hours(nanoseconds1) == to_hours(nanoseconds2)
  end
  
  
  
  @doc """
  Verify if two nano seconds obtained by ```System.os_time()```
  match in same minute of same hour of ... of same year. 
  
  Useful if you want controll use of resources by time interval. 
  """  
  def same_minute(nanoseconds1,nanoseconds2) do
    to_minutes(nanoseconds1) == to_minutes(nanoseconds2)
  end
  
  
  
  @doc """
  Verify if two nano seconds obtained by ```System.os_time()```
  match in same second of same minute of same ... of same year.
   
  Useful if you want controll use of resources by time interval. 
  """  
  def same_second(nanoseconds1,nanoseconds2) do
    to_seconds(nanoseconds1) == to_seconds(nanoseconds2)
  end
  
  
  
  defp sql_date_to_date_time(sql_date) do
    sql_date = sql_date |> String.slice(0..18)
    date_arr = sql_date |> StringUtil.trim() |> StringUtil.split(" ")
    date_arr1 = date_arr |> Enum.at(0) |> StringUtil.split("-")
    date_arr2 = date_arr |> Enum.at(1) |> StringUtil.split(":")
    year = date_arr1 |> Enum.at(0) |> NumberUtil.to_integer()
    month = date_arr1 |> Enum.at(1) |> NumberUtil.to_integer()
    day = date_arr1 |> Enum.at(2) |> NumberUtil.to_integer()
    hour = date_arr2 |> Enum.at(0) |> NumberUtil.to_integer()
    minute = date_arr2 |> Enum.at(1) |> NumberUtil.to_integer()
    second = date_arr1 |> Enum.at(2) |> NumberUtil.to_integer()
    %DateTime{year: year, month: month, day: day,hour: hour, minute: minute, second: second,
              zone_abbr: "GMT", utc_offset: -10800, std_offset: 0, time_zone: "America/Sao Paulo"}
  end
  
  
  
  defp get_now_to_sql_internal(date,begin_day,end_day) do
    year = date.year
    month = StringUtil.left_zeros(date.month,2)
    day = StringUtil.left_zeros(date.day,2)
    string_date = Enum.join([year,month,day],"-")
    cond do
      begin_day ->  Enum.join([string_date,"00:00:00"]," ")
      end_day ->  Enum.join([string_date,"23:59:59"]," ")
      true -> Enum.join([string_date,get_time_now_string()]," ")
    end
  end
  
  
  
  defp to_years(nanoseconds) do
    div(to_months(nanoseconds),365)
  end
  
  
  
  defp to_months(nanoseconds) do
    div(to_days(nanoseconds),30)
  end
  
  
  
  defp to_days(nanoseconds) do
    div(to_hours(nanoseconds),24)
  end
  
  
  
  defp to_hours(nanoseconds) do
    div(to_minutes(nanoseconds),60)
  end
  
  
  
  defp to_minutes(nanoseconds) do
    div(to_seconds(nanoseconds),60)
  end
  
  
  
  defp to_seconds(nanoseconds) do
    div(nanoseconds,1000000000)
  end
  
  
  
end