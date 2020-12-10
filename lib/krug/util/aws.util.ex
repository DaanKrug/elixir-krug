defmodule Krug.AWSUtil do

  @moduledoc """
  Utilitary module to work with ExAws API.
  """



  @doc """
  Makes ExAws.request methods call and handle the result. 
  
  Return nil if error, otherwise return AWS response.

  ## Example - Verification if a file was successfully uploaded to AWS S3

  ```elixir 
  config = Keyword.put([],     :bucket_name,        "aws S3 bucket name")
  config = Keyword.put(config, :bucket_url,         "aws S3 bucket url")
  config = Keyword.put(config, :version,           "aws S3 bucket version")
  config = Keyword.put(config, :access_key_id,     "aws S3 bucket access key id")
  config = Keyword.put(config, :secret_access_key, "aws S3 bucket access key")
  config = Keyword.put(config, :region,            "aws S3 bucket region")
  uploaded_file = ExAws.S3.put_object(bucket_name,file_dir,binary,[acl: :public_read])  
  file = Krug.AWSUtil.make_aws_request(uploaded_file,config)
  (nil != file and file)
  ```
  """
  def make_aws_request(object,config_override) do
  	ExAws.request(object,config_override) |> get_aws_request_result()
  end


  
  defp get_aws_request_result({:ok, term}) do
    #IO.puts("SUCCESS: get_aws_request_result")
    #IO.inspect(term)
    term
  end


  
  defp get_aws_request_result({:error, _term}) do
    #IO.puts("ERROR: get_aws_request_result")
    #IO.inspect(term)
    nil
  end


  
end