defmodule Krug.AWSUtil do

  @moduledoc """
  Utilitary module to work whit ExAws API.
  """



  @doc """
  Makes ExAws.request methods call and handle the result. 
  
  Return nil if error, otherwise return AWS response.

  ## Example - Verification if a file was successfully uploaded to AWS S3

  ```elixir 
  config = Keyword.put([],     :bucketName,        "aws S3 bucket name")
  config = Keyword.put(config, :bucketUrl,         "aws S3 bucket url")
  config = Keyword.put(config, :version,           "aws S3 bucket version")
  config = Keyword.put(config, :access_key_id,     "aws S3 bucket access key id")
  config = Keyword.put(config, :secret_access_key, "aws S3 bucket access key")
  config = Keyword.put(config, :region,            "aws S3 bucket region")
  uploadedFile = ExAws.S3.put_object(bucketName,fileDir,binary,[acl: :public_read])  
  file = Krug.AWSUtil.makeAwsRequest(uploadedFile,config)
  (nil != file and file)
  ```
  """
  def makeAwsRequest(object,configOverrides) do
  	ExAws.request(object,configOverrides) |> getAwsRequestResult()
  end


  
  defp getAwsRequestResult({:ok, term}) do
    #IO.puts("SUCCESS: getAwsRequestResult")
    #IO.inspect(term)
    term
  end


  
  defp getAwsRequestResult({:error, _term}) do
    #IO.puts("ERROR: getAwsRequestResult")
    #IO.inspect(term)
    nil
  end


  
end