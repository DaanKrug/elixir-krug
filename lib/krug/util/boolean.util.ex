defmodule Krug.BooleanUtil do

  @bool_list [true,"true",1,"1"]

  @moduledoc """
  Utilitary module for simplify some Boolean operations.
  """
  
  @doc """
  Compares 2 values verifing if are equals in boolean conversion.

  ## Examples

  ```elixir 
  iex > Krug.BooleanUtil.equals(true,true)
  true
  ```
  ```elixir 
  iex > Krug.BooleanUtil.equals("true",true)
  true
  ```
  ```elixir 
  iex > Krug.BooleanUtil.equals(1,1)
  true
  ```
  ```elixir 
  iex > Krug.BooleanUtil.equals(true,1)
  true
  ```
  ```elixir 
  iex > Krug.BooleanUtil.equals(true,"1")
  true
  ```
  ```elixir 
  iex > Krug.BooleanUtil.equals(1,"1")
  true
  ```
  ```elixir 
  iex > Krug.BooleanUtil.equals("1","1")
  true
  ```
  ```elixir 
  iex > Krug.BooleanUtil.equals("0","0")
  true
  ```
  ```elixir 
  iex > Krug.BooleanUtil.equals("false","0")
  true
  ```
  ```elixir 
  iex > Krug.BooleanUtil.equals("false",0)
  true
  ```
  ```elixir 
  iex > Krug.BooleanUtil.equals("false","true")
  false
  ```
  ```elixir 
  iex > Krug.BooleanUtil.equals("A","B")
  true
  ```
  ```elixir 
  iex > Krug.BooleanUtil.equals("A",true)
  false
  ```
  """
  def equals(boolean1,boolean2) do
    Enum.member?(@bool_list,boolean1) == Enum.member?(@bool_list,boolean2)
  end
  
end