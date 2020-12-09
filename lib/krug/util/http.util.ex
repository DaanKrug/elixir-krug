defmodule Krug.HttpUtil do

  @moduledoc """
  Utilitary module to handle HTTPoison requests and respectives fail/responses.
  
  Useful to access external services whit CORS restrictions in browser,
  or services that involves use of credentials that don't should be send/stored
  in browser/UI.
  """



  @doc """
  Makes a ```GET``` request to a url.
  
  In case of success return a response.body. 
  
  If fail return nil. 
  
  If fail and was received a debug parameter as ```true```, then return the fail reason.

  ## Examples

  ```elixir 
  iex > url = "www.google.com"
  iex > Krug.HttpUtil.makeGetRequest(url)
  "<!doctype html><html ..."
  ```
  ```elixir 
  iex > fakeUrl = "www.fakeurl.xxx"
  iex > Krug.HttpUtil.makeGetRequest(fakeUrl)
  nil
  ```
  ```elixir 
  iex > fakeUrl = "www.fakeurl.xxx"
  iex > Krug.HttpUtil.makeGetRequest(fakeUrl,[],[],true)
  %HTTPoison.Error{id: nil, reason: :nxdomain}
  ```
  """
  def makeGetRequest(url,headers \\ [], options \\ [],debug \\ false) do
    HTTPoison.get(url,headers,options) |> handleResponse(debug)
  end
  
  
  
  @doc """
  Makes a ```POST``` request to a url.
  
  In case of success return a response.body. 
  
  If fail return nil. 
  
  If fail and was received a debug parameter as ```true```, then return the fail reason.

  ## Examples

  ```elixir 
  iex > url = "www.google.com"
  iex > jsonbody = "{search: \"ping\"}"
  iex > Krug.HttpUtil.makePostRequest(url,jsonbody)
  "<!doctype html><html ... Error 405 (Method Not Allowed) ..."
  ```
  ```elixir 
  iex > fakeUrl = "www.fakeurl.xxx"
  iex > Krug.HttpUtil.makePostRequest(fakeUrl,jsonbody)
  nil
  ```
  ```elixir 
  iex > fakeUrl = "www.fakeurl.xxx"
  iex > Krug.HttpUtil.makePostRequest(fakeUrl,jsonbody,[],[],true)
  %HTTPoison.Error{id: nil, reason: :nxdomain}
  ```
  """
  def makePostRequest(url,jsonbody,headers \\ [], options \\ [],debug \\ false) do
    HTTPoison.post(url,jsonbody,headers,options) |> handleResponse(debug)
  end
  
  
  
  @doc """
  Makes a ```PUT``` request to a url.
  
  In case of success return a response.body. 
  
  If fail return nil. 
  
  If fail and was received a debug parameter as ```true```, then return the fail reason.

  ## Examples

  ```elixir 
  iex > url = "www.google.com"
  iex > jsonbody = "{search: \"ping\"}"
  iex > Krug.HttpUtil.makePutRequest(url,jsonbody)
  "<!doctype html><html ... Error 405 (Method Not Allowed) ..."
  ```
  ```elixir 
  iex > fakeUrl = "www.fakeurl.xxx"
  iex > Krug.HttpUtil.makePutRequest(fakeUrl,jsonbody)
  nil
  ```
  ```elixir 
  iex > fakeUrl = "www.fakeurl.xxx"
  iex > Krug.HttpUtil.makePutRequest(fakeUrl,jsonbody,[],[],true)
  %HTTPoison.Error{id: nil, reason: :nxdomain}
  ```
  """
  def makePutRequest(url,jsonbody,headers \\ [], options \\ [],debug \\ false) do
    HTTPoison.put(url,jsonbody,headers,options) |> handleResponse(debug)
  end
  
  
  
  @doc """
  Makes a ```PATCH``` request to a url.
  
  In case of success return a response.body. 
  
  If fail return nil. 
  
  If fail and was received a debug parameter as ```true```, then return the fail reason.

  ## Examples

  ```elixir 
  iex > url = "www.google.com"
  iex > jsonbody = "{search: \"ping\"}"
  iex > Krug.HttpUtil.makePatchRequest(url,jsonbody)
  "<!doctype html><html ... Error 405 (Method Not Allowed) ..."
  ```
  ```elixir 
  iex > fakeUrl = "www.fakeurl.xxx"
  iex > Krug.HttpUtil.makePatchRequest(fakeUrl,jsonbody)
  nil
  ```
  ```elixir 
  iex > fakeUrl = "www.fakeurl.xxx"
  iex > Krug.HttpUtil.makePatchRequest(fakeUrl,jsonbody,[],[],true)
  %HTTPoison.Error{id: nil, reason: :nxdomain}
  ```
  """
  def makePatchRequest(url,jsonbody,headers \\ [], options \\ [],debug \\ false) do
    HTTPoison.patch(url,jsonbody,headers,options) |> handleResponse(debug)
  end
  
  
  
  @doc """
  Makes a ```DELETE``` request to a url.
  
  In case of success return a response.body. 
  
  If fail return nil. 
  
  If fail and was received a debug parameter as ```true```, then return the fail reason.

  ## Examples

  ```elixir 
  iex > url = "www.google.com"
  iex > Krug.HttpUtil.makeDeleteRequest(url)
  "<!doctype html><html ... Error 405 (Method Not Allowed) ..."
  ```
  ```elixir 
  iex > fakeUrl = "www.fakeurl.xxx"
  iex > Krug.HttpUtil.makeDeleteRequest(fakeUrl)
  nil
  ```
  ```elixir 
  iex > fakeUrl = "www.fakeurl.xxx"
  iex > Krug.HttpUtil.makeDeleteRequest(fakeUrl,[],[],true)
  %HTTPoison.Error{id: nil, reason: :nxdomain}
  ```
  """
  def makeDeleteRequest(url,headers \\ [], options \\ [],debug \\ false) do
    HTTPoison.delete(url,headers,options) |> handleResponse(debug)
  end
  
  
  
  defp handleResponse({:ok,response},_debug) do
  	response.body
  end
  
  
  
  defp handleResponse({:error,reason},debug) do
    cond do
      (debug) -> reason
      true -> nil
    end
  end



end