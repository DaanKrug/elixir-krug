defmodule Krug.CipherUtil do

  @moduledoc """
  Utilitary module for get help on cipher operations.
  """
  @moduledoc since: "1.1.41"
  
  alias Krug.StringUtil
  alias Krug.MathUtil
  
  
  @doc """
  Calculates the unique number from a string.
  
  You could use "skip_verification" parameter as true, if you are sure that
  values already were verified (not nil/empty and not need be trimmed), this will improve performance.

  ## Examples

  ```elixir 
  iex > Krug.CipherUtil.calculate_string_value(nil)
  0
  ```
  ```elixir 
  iex > Krug.CipherUtil.calculate_string_value("")
  0
  ```
  ```elixir 
  iex > Krug.CipherUtil.calculate_string_value(" ")
  0
  ```
  ```elixir 
  iex > Krug.CipherUtil.calculate_string_value("A")
  130
  ```
  ```elixir 
  iex > Krug.CipherUtil.calculate_string_value("echo.ping@blabla.com")
  217583302
  ```
  ```elixir 
  iex > Krug.CipherUtil.calculate_string_value("jhon.titor@timetraveler.com")
  28001410572
  ```
  """
  def calculate_string_value(string,skip_verification \\ false) do
    cond do
      (skip_verification)
        -> string
             |> String.graphemes()
             |> calculate_string_value_graphemes()
      (nil == string
        or string |> StringUtil.trim() == "")
          -> 0
      true
        -> string
             |> StringUtil.trim()
             |> String.graphemes()
             |> calculate_string_value_graphemes() 
    end
  end
  
  
  
  defp calculate_string_value_graphemes(graphemes,unique_number \\ 0,counter \\ 1) do
    cond do
      (Enum.empty?(graphemes))
        -> unique_number
      true
        -> graphemes
             |> tl()
             |> calculate_string_value_graphemes(
                  graphemes |> hd() |> calculate_grapheme(unique_number,counter),
                  counter + 1
                )
    end
  end



  defp calculate_grapheme(grapheme,unique_number,counter) do
    factor = MathUtil.pow(2,counter)
    <<char_code::utf8>> = grapheme
    (char_code * factor) + unique_number
  end
	
end


