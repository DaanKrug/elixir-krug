defmodule Krug.HttpUtil do

  @moduledoc """
  Utilitary module to handle HTTPoison requests and respectives fail/responses.
  
  Useful to access external services with CORS restrictions in browser,
  or services that involves use of credentials that don't should be send/stored
  in browser/UI.
  """



  @doc """
  Makes a ```GET``` request to a url.
  
  In case of success return a response.body. 
  
  If fail return nil. 
  
  If fail and was received a debug parameter as ```true```, then return the fail reason.
  
  The extra parameter 'full_response' returns the object 'response' if true
  or 'response.body' if false.
  make_get_request(url,headers \\ [], options \\ [],debug \\ false,full_response \\ false)

  ## Examples

  ```elixir 
  iex > url = "www.google.com"
  iex > Krug.HttpUtil.make_get_request(url)
  "<!doctype html><html ..."
  ```
  ```elixir 
  iex > fake_url = "www.fake_url.xxx"
  iex > Krug.HttpUtil.make_get_request(fake_url)
  nil
  ```
  ```elixir 
  iex > fake_url = "www.fake_url.xxx"
  iex > Krug.HttpUtil.make_get_request(fake_url,[],[],true)
  %HTTPoison.Error{id: nil, reason: :nxdomain}
  ```
  """
  def make_get_request(url,headers \\ [], options \\ [],debug \\ false,full_response \\ false) do
    HTTPoison.get(url,headers,options) |> handle_response(debug,full_response)
  end
  
  
  
  @doc """
  Makes a ```POST``` request to a url.
  
  In case of success return a response.body. 
  
  If fail return nil. 
  
  If fail and was received a debug parameter as ```true```, then return the fail reason.
  
  The extra parameter 'full_response' returns the object 'response' if true
  or 'response.body' if false.
  make_post_request(url,headers \\ [], options \\ [],debug \\ false,full_response \\ false)

  ## Examples

  ```elixir 
  iex > url = "www.google.com"
  iex > json_body = "{search: \"ping\"}"
  iex > Krug.HttpUtil.make_post_request(url,json_body)
  "<!doctype html><html ... Error 405 (Method Not Allowed) ..."
  ```
  ```elixir 
  iex > fake_url = "www.fake_url.xxx"
  iex > Krug.HttpUtil.make_post_request(fake_url,json_body)
  nil
  ```
  ```elixir 
  iex > fake_url = "www.fake_url.xxx"
  iex > Krug.HttpUtil.make_post_request(fake_url,json_body,[],[],true)
  %HTTPoison.Error{id: nil, reason: :nxdomain}
  ```
  """
  def make_post_request(url,json_body,headers \\ [], options \\ [],debug \\ false,full_response \\ false) do
    HTTPoison.post(url,json_body,headers,options) |> handle_response(debug,full_response)
  end
  
  
  
  @doc """
  Makes a ```PUT``` request to a url.
  
  In case of success return a response.body. 
  
  If fail return nil. 
  
  If fail and was received a debug parameter as ```true```, then return the fail reason.
  
  The extra parameter 'full_response' returns the object 'response' if true
  or 'response.body' if false.
  make_put_request(url,headers \\ [], options \\ [],debug \\ false,full_response \\ false)

  ## Examples

  ```elixir 
  iex > url = "www.google.com"
  iex > json_body = "{search: \"ping\"}"
  iex > Krug.HttpUtil.make_put_request(url,json_body)
  "<!doctype html><html ... Error 405 (Method Not Allowed) ..."
  ```
  ```elixir 
  iex > fake_url = "www.fake_url.xxx"
  iex > Krug.HttpUtil.make_put_request(fake_url,json_body)
  nil
  ```
  ```elixir 
  iex > fake_url = "www.fake_url.xxx"
  iex > Krug.HttpUtil.make_put_request(fake_url,json_body,[],[],true)
  %HTTPoison.Error{id: nil, reason: :nxdomain}
  ```
  """
  def make_put_request(url,json_body,headers \\ [], options \\ [],debug \\ false,full_response \\ false) do
    HTTPoison.put(url,json_body,headers,options) |> handle_response(debug,full_response)
  end
  
  
  
  @doc """
  Makes a ```PATCH``` request to a url.
  
  In case of success return a response.body. 
  
  If fail return nil. 
  
  If fail and was received a debug parameter as ```true```, then return the fail reason.
  
  The extra parameter 'full_response' returns the object 'response' if true
  or 'response.body' if false.
  make_patch_request(url,headers \\ [], options \\ [],debug \\ false,full_response \\ false)

  ## Examples

  ```elixir 
  iex > url = "www.google.com"
  iex > json_body = "{search: \"ping\"}"
  iex > Krug.HttpUtil.make_patch_request(url,json_body)
  "<!doctype html><html ... Error 405 (Method Not Allowed) ..."
  ```
  ```elixir 
  iex > fake_url = "www.fake_url.xxx"
  iex > Krug.HttpUtil.make_patch_request(fake_url,json_body)
  nil
  ```
  ```elixir 
  iex > fake_url = "www.fake_url.xxx"
  iex > Krug.HttpUtil.make_patch_request(fake_url,json_body,[],[],true)
  %HTTPoison.Error{id: nil, reason: :nxdomain}
  ```
  """
  def make_patch_request(url,json_body,headers \\ [], options \\ [],debug \\ false,full_response \\ false) do
    HTTPoison.patch(url,json_body,headers,options) |> handle_response(debug,full_response)
  end
  
  
  
  @doc """
  Makes a ```DELETE``` request to a url.
  
  In case of success return a response.body. 
  
  If fail return nil. 
  
  If fail and was received a debug parameter as ```true```, then return the fail reason.
  
  The extra parameter 'full_response' returns the object 'response' if true
  or 'response.body' if false.
  make_delete_request(url,headers \\ [], options \\ [],debug \\ false,full_response \\ false)

  ## Examples

  ```elixir 
  iex > url = "www.google.com"
  iex > Krug.HttpUtil.make_delete_request(url)
  "<!doctype html><html ... Error 405 (Method Not Allowed) ..."
  ```
  ```elixir 
  iex > fake_url = "www.fake_url.xxx"
  iex > Krug.HttpUtil.make_delete_request(fake_url)
  nil
  ```
  ```elixir 
  iex > fake_url = "www.fake_url.xxx"
  iex > Krug.HttpUtil.make_delete_request(fake_url,[],[],true)
  %HTTPoison.Error{id: nil, reason: :nxdomain}
  ```
  """
  def make_delete_request(url,headers \\ [], options \\ [],debug \\ false,full_response \\ false) do
    HTTPoison.delete(url,headers,options) |> handle_response(debug,full_response)
  end
  
  
  
  defp handle_response({:ok,response},_debug,full_response) do
    cond do
      (full_response) -> response
      true -> response.body
    end
  end
  
  
  
  defp handle_response({:error,reason},debug,_full_response) do
    cond do
      (debug) -> reason
      true -> nil
    end
  end



end