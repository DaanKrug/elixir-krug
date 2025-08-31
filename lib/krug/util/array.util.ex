defmodule Krug.ArrayUtil do

  @moduledoc """
  Utilitary module to handle array transformations.
  """
  
  @doc """
  Rotates an ```array``` X ```positions``` in direction from left to right.
  A initial array [1,2,3,4] turn in [2,3,4,1] if rotate ```positions``` equal 
  to 1.
  
  The parameter ```unsafe``` can be set to true when you have total sure that all parameters are
  not null/empty. This will improve some performance.
  
  ## Examples
  
  ```elixir
  iex > Krug.ArrayUtil.rotate_right(nil,1)
  nil
  ```
  ```elixir
  iex > Krug.ArrayUtil.rotate_right([],1)
  []
  ```
  ```elixir
  iex > Krug.ArrayUtil.rotate_right([1],2)
  [1]
  ```
  ```elixir
  iex > Krug.ArrayUtil.rotate_right([1,2,3,4],nil)
  [1,2,3,4]
  ```
  ```elixir
  iex > Krug.ArrayUtil.rotate_right([1,2,3,4],1)
  [2,3,4,1]
  ```
  ```elixir
  iex > Krug.ArrayUtil.rotate_right([1,2,3,4],3)
  [4,1,2,3]
  ```
  """
  @doc since: "0.4.3"
  def rotate_right(array,positions,unsafe \\ false) do
    cond do
      (unsafe)
        -> array
             |> rotate_right2(positions)
      (nil == array 
        or Enum.empty?(array)) 
          -> array
      (nil == positions 
        or !(positions > 0)) 
          -> array
      true 
        -> array
             |> rotate_right2(positions)
    end
  end
  
  
  
  @doc """
  Rotates an ```array``` X ```positions``` in direction from right to left.
  A initial array [1,2,3,4] turn in [4,1,2,3] if rotate ```positions``` equal 
  to 1.
  
  The parameter ```unsafe``` can be set to true when you have total sure that all parameters are
  not null/empty. This will improve some performance.
  
  ## Examples
  
  ```elixir
  iex > Krug.ArrayUtil.rotate_left(nil,1)
  nil
  ```
  ```elixir
  iex > Krug.ArrayUtil.rotate_left([],1)
  []
  ```
  ```elixir
  iex > Krug.ArrayUtil.rotate_left([1],2)
  [1]
  ```
  ```elixir
  iex > Krug.ArrayUtil.rotate_left([1,2,3,4],1)
  [4,1,2,3]
  ```
  ```elixir
  iex > Krug.ArrayUtil.rotate_left([1,2,3,4],3)
  [2,3,4,1]
  ```
  """
  @doc since: "0.4.3"
  def rotate_left(array,positions,unsafe \\ false) do
    cond do
      (unsafe)
        -> array
             |> rotate_left2(positions)
      (nil == array 
        or Enum.empty?(array)) 
          -> array
      (nil == positions 
        or !(positions > 0)) 
          -> array
      true 
        -> array
             |> rotate_left2(positions)
    end
  end
  
  
  
  defp rotate_right2(array,positions) do
    size = length(array)
    remainder = rem(positions,size)
    cond do
      (remainder == 0 
        or size < 2) 
          -> array
      true 
        -> array 
             |> rotate_right3(remainder) ## |> rotate_right_positions(remainder,0)
    end
  end
  
  
  
  defp rotate_right3(array,positions) do
    {left, right} = Enum.split(array, positions)
    right ++ left
  end
  
  
  
  defp rotate_left2(array,positions) do
    size = length(array)
    remainder = rem(positions,size)
    cond do
      (remainder == 0 
        or size < 2) 
          -> array
      true 
        -> array
             |> rotate_left3(size,remainder) ## |> rotate_left_positions(remainder,0)
    end
  end
  
  
  
  defp rotate_left3(array,size,positions) do
    {left, right} = Enum.split(array, size - positions)
    right ++ left
  end
  
  
  
  #defp rotate_right_positions(array,positions,count) do
  #  cond do
  #    (count >= positions) 
  #      -> array
  #    true 
  #      -> array
  #           |> rotate_right_one_position() 
  #           |> rotate_right_positions(positions,count + 1)
  #  end
  #end
  
  
  
  #defp rotate_right_one_position(array) do
  #  [
  #    (array |> hd()) 
  #      | (array |> tl() |> Enum.reverse())
  #  ] 
  #    |> Enum.reverse()
  #end
  
  
  
  #defp rotate_left_positions(array,positions,count) do
  #  cond do
  #    (count >= positions) 
  #      -> array
  #    true 
  #      -> array
  #           |> rotate_left_one_position() 
  #           |> rotate_left_positions(positions,count + 1)
  #  end
  #end
  
  
  
  #defp rotate_left_one_position(array) do
  #  array = array |> Enum.reverse()
  #  [
  #    (array |> hd()) 
  #      | (array |> tl() |> Enum.reverse())
  #  ]
  #end
  
  
  
end