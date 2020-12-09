defmodule Krug.ImageUtil do

  @moduledoc """
  Utilitary module to work whit images.
  """

  alias Krug.StringUtil
  
  
  
  @doc """
  Validates a url relative to a image stored in cloud. 
  
  Should be an ```HTTPS``` link and the image should be of type: ```["png","bmp","jpg","jpeg","gif"]```.
  
  Useful to block the use of images that don't are serverd over https protocol
  and could break application security.

  ## Examples

  ```elixir 
  iex > url = "www.google.com"
  iex > Krug.ImageUtil.validateUrl(url)
  false
  ```
  ```elixir 
  iex > url = "http://www.google.com"
  iex > Krug.ImageUtil.validateUrl(url)
  false
  ```
  ```elixir 
  iex > url = "https://www.google.com.br"
  iex > Krug.ImageUtil.validateUrl(url)
  false
  ```
  ```elixir 
  iex > url = "https://www.google.com.png"
  iex > Krug.ImageUtil.validateUrl(url)
  true
  ```
  ```elixir 
  iex > url = "https://www.google.com.gif"
  iex > Krug.ImageUtil.validateUrl(url)
  true
  ```
  """
  def validateUrl(url) do
    url = url |> StringUtil.trim()
    cond do
      (!(String.contains?(url,"https://")) or !(String.contains?(url,"."))) -> false
      (String.length(url) < 13) -> false
      (url |> StringUtil.split(":") |> Enum.at(0) != "https") -> false
      true -> url |> StringUtil.split(".") |> validateUrlExtension()
    end
  end


  
  defp validateUrlExtension(arr) do
    ext = Enum.at(arr,length(arr) - 1) |> StringUtil.trim() |> String.downcase()
    Enum.member?(["png","bmp","jpg","jpeg","gif"],ext)
  end


  
end