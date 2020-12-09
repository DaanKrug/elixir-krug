defmodule Krug.FileUtil do

  @moduledoc """
  Utilitary module to handle files and directories.
  """
  
  alias Krug.StringUtil
  
  
  
  @doc """
  Creates a new directory with name specified. 
  
  If already exists a directory whit this name, only preserve these directory. 
  
  If exists a file whit this name try delete the file before create a new directory.
  Return false if this file cannot be deleted.
  
  Finally change permissions of these dir to 777 (chmod), in success case.
  
  ## Example

  ```elixir 
  iex > Krug.FileUtil.createDir(path)
  true (or false if fail)
  ```
  """
  def createDir(path) do
  	cond do
      (File.exists?(path) and File.dir?(path)) -> chmod(path,0o777)
      (File.exists?(path) and !(File.dir?(path)) and !(drop(path))) -> false
      (:ok != File.mkdir(path)) -> false
      true -> chmod(path,0o777)
    end
  end
  
  
  
  @doc """
  Copy the content of a directory to another directory.
  
  Finally change permissions of the destination directory to 777 (chmod), in success case.

  ## Example

  ```elixir 
  iex > Krug.FileUtil.copyDir(fromDir,toDir)
  true (or false if fail)
  ```
  """
  def copyDir(fromDir,toDir) do
    result = cond do
      (!(File.exists?(fromDir)) or !(File.dir?(fromDir))) -> {:error, :enotdir}
      (!(File.exists?(toDir)) or !(File.dir?(toDir))) -> {:error, :enotdir}
      true -> File.cp_r(fromDir,toDir)
    end
    cond do
      (:ok != result |> Tuple.to_list() |> Enum.at(0)) -> false
      true -> chmod(toDir,0o777)
    end
  end
  
  
  
  @doc """
  Delete a directory whit specified name. 
  
  Return false if the directory don't exists and parameter ignoreIfDontExists is false/don't received.
  
  If the name is a file and not a diectory, return false.
  
  ## Examples

  ```elixir 
  iex > Krug.FileUtil.dropDir(path)
  true (or false if fail)
  ```
  ```elixir 
  iex > Krug.FileUtil.dropDir(path,true)
  true (or false if fail)
  ```
  """
  def dropDir(path,ignoreIfDontExists \\ false) do
    result = cond do
      (ignoreIfDontExists and !(File.exists?(path))) -> {:ok, "OK"}
      (!(File.exists?(path)) or !(File.dir?(path))) -> {:error, :enotdir}
      true -> File.rm_rf(path)
    end
    (:ok == result |> Tuple.to_list() |> Enum.at(0))
  end
  
  
  
  @doc """
  Copy a file to another file. 
  
  Return false if a destination file
  already exists and the parameter ignoreIfExists don't was received as true.
  
  Finally change permissions of the destination file to 777 (chmod), in success case.

  ## Examples

  ```elixir 
  iex > Krug.FileUtil.copyFile(fromFile,toFile)
  true (or false if fail)
  ```
  ```elixir 
  iex > Krug.FileUtil.copyFile(fromFile,toFile,true)
  true (or false if fail)
  ```
  """
  def copyFile(fromFile,toFile,ignoreIfExists \\ true) do
    result = cond do
      (!(File.exists?(fromFile))) -> {:error, :enoent}
      (!ignoreIfExists and File.exists?(toFile)) -> {:error, :eexist}
      true -> File.copy(fromFile,toFile)
    end
    cond do
      (:ok != result |> Tuple.to_list() |> Enum.at(0)) -> false
      true -> chmod(toFile,0o777)
    end
  end
  
  
  
  @doc """
  Delete a file. 
  
  Return false if the file don't exists and
  the parameter ignoreIfDontExists don't was received as true.
  
  If file is a directory, return false.
  
  ## Examples

  ```elixir 
  iex > Krug.FileUtil.dropFile(path)
  true (or false if fail)
  ```
  ```elixir 
  iex > Krug.FileUtil.dropFile(path,true)
  true (or false if fail)
  ```
  """
  def dropFile(path,ignoreIfDontExists \\ false) do
    cond do
      (ignoreIfDontExists and !(File.exists?(path))) -> true
      (!(File.exists?(path)) or File.dir?(path)) -> false
      true -> drop(path)
    end
  end
  
  
  
  @doc """
  Read a content of a file. 
  
  Return nil file is a directory, or don't exists, or 
  the operation failed on open/read the file.
  
  ## Example

  ```elixir 
  iex > Krug.FileUtil.readFile(path)
  file content (or nil)
  ```
  """
  def readFile(path) do
    cond do
      (!(File.exists?(path)) or File.dir?(path)) -> nil
      true -> File.read(path) |> readContent()
    end
  end
  
  
  
  @doc """
  Change the file/directory permissions. 
  
  Return true if the file/directory exists
  and the permissions are correctly changed.
  
  Permission should be initiate whit ```0o``` chars 
  (for example ```0o777```, ```0o755```, ```0o744```, ```0o600```).
  
  ## Example

  ```elixir 
  iex > Krug.FileUtil.chmod(path,0o777)
  true (or false if fail)
  ```
  """
  def chmod(path,permission) do
  	(:ok == File.chmod(path,permission))
  end
  
  
  
  @doc """
  Write a content in a file, if the file exists and is a file (not directory).
  
  If the parameter insertionPoints and parameter insertionPointTag are received,
  the content original is preserved and content received is inserted
  before of insertionPointTag and beetwen insertionPoints[0] and insertionPoints[1].
  (insertionPoints are write in this moment, and could be used to remove this content later).
  
  If insertionPointTag is received and don't exists in file, return false.
  
  Accept only file extensions: ```["sql","txt","html","ts","js","ex","exs","sh","json"]```
  will fail for other file extensions.

  ## Examples

  ```elixir 
  iex > Krug.FileUtil.write(path,content)
  true (or false if fail)
  ```
  ```elixir 
  iex > Krug.FileUtil.write(path,content,["markerBegin","markerEnd"],"markerInsertion")
  true (or false if fail)
  ```
  """
  def write(path,content,insertionPoints \\ [],insertionPointTag \\ nil) do
    arr = cond do
      (!(String.contains?(path,"."))) -> []
      true -> StringUtil.split(path,".")
    end
    ext = cond do
      (length(arr) > 1) -> Enum.at(arr,length(arr) - 1) 
      true -> ""
    end
    cond do
      (File.exists?(path) and File.dir?(path)) -> false
      (!(length(arr) > 1)) -> false
      (!(Enum.member?(validExtensions(),ext))) -> false
      (nil != insertionPoints and length(insertionPoints) == 2 
        and nil != insertionPointTag and StringUtil.trim(insertionPointTag) != "") 
          -> insertInFile(path,content,insertionPoints,insertionPointTag) 
      true -> writeToFile(path,content)
    end
  end
  
  
  
  @doc """
  Remove the content of a file if that is located between insertionPoints[0] and insertionPoints[1].
  The insertionPoints are removed too.
  
  Fail if the file don't exists, is a directory, operation fail, or the 
  insertionPoints[0] or insertionPoints[1] don't exists in file.
  
  Accept only file extensions: ```["sql","txt","html","ts","js","ex","exs","sh","json"]```
  will fail for other file extensions.

  ## Example

  ```elixir 
  iex > Krug.FileUtil.remove(path,["markerBegin","markerEnd"])
  true (or false if fail)
  ```
  """
  def remove(path,insertionPoints) do
    arr = cond do
      (!(String.contains?(path,"."))) -> []
      true -> StringUtil.split(path,".")
    end
    ext = cond do
      (length(arr) > 1) -> Enum.at(arr,length(arr) - 1) 
      true -> ""
    end
    cond do
      (File.exists?(path) and File.dir?(path)) -> false
      (!(length(arr) > 1)) -> false
      (!(Enum.member?(validExtensions(),ext))) -> false
      (nil != insertionPoints and length(insertionPoints) == 2) -> removeFromFile(path,insertionPoints) 
      true -> false
    end
  end
  
  
  
  @doc """
  Replaces all ocurrences of a ```searchBy``` parameter value 
  by ```replaceTo``` parameter value in the file.
  
  Fail if the file is directory or don't exists.
  
  Accept only file extensions: ```["sql","txt","html","ts","js","ex","exs","sh","json"]```
  will fail for other file extensions.

  ## Example

  ```elixir 
  iex > Krug.FileUtil.replaceInFile(path,"AA","BB")
  true (or false if fail)
  ```
  """
  def replaceInFile(path,searchBy,replaceTo) do
    arr = cond do
      (!(String.contains?(path,"."))) -> []
      true -> StringUtil.split(path,".")
    end
    ext = cond do
      (length(arr) > 1) -> Enum.at(arr,length(arr) - 1) 
      true -> ""
    end
    cond do
      (!File.exists?(path) or File.dir?(path)) -> false
      (!(Enum.member?(validExtensions(),ext))) -> false
      true -> replaceInFile(File.read(path),path,searchBy,replaceTo)
    end
  end
  
  
  
  defp readContent({:ok, binary}) do
    cond do
      (nil == binary) -> nil
      true -> "#{binary}" |> StringUtil.trim()
    end
  end
  
  
  
  defp readContent({:error, _reason}) do
    #IO.puts(":error in readContent:")
    #IO.inspect(reason)
    nil
  end
  
  
  
  defp writeToFile(path,content) do  
    cond do
      (!(drop(path))) -> false
      (!(openAndWrite(File.open(path,[:write]),path,content))) -> false
      true -> true
    end
  end
  
  
  
  defp openAndWrite({:ok, file},path,content) do
    IO.write(file,content)
    File.close(file)
    chmod(path,0o777)
    true
  end
  
  
  
  defp openAndWrite({:error,_reason},_path,_content) do
    #IO.puts(":error in openAndWrite:")
    #IO.inspect(reason)
    false
  end
  
  
  
  defp drop(path) do
    result = cond do
      (File.exists?(path)) -> File.rm(path)
      true -> :ok
    end
    (result == :ok)
  end
  
  
  
  defp validExtensions() do
    ["sql","txt","html","ts","js","ex","exs","sh","json"]
  end
  
  
  
  defp replaceInFile({:ok,content},path,searchBy,replaceTo) do
    contentNew = cond do
      (searchBy |> StringUtil.trim() == "") -> nil
      (replaceTo |> StringUtil.trim() == "") -> nil
      true -> content |> StringUtil.replace(searchBy,replaceTo)
    end
    cond do
      (contentNew == nil) -> false
      true -> writeToFile(path,contentNew)
    end
  end
  
  
  
  defp replaceInFile({:error,_reason},_path,_searchBy,_replaceTo) do
    #IO.puts(":error in replaceInFile:")
    #IO.inspect(reason)
    false
  end
  
  
  
  defp insertInFile(path,contentInsert,insertionPoints,insertionPointTag) do
    insertInFile(File.read(path),path,contentInsert,insertionPoints,insertionPointTag)
  end
  
  
  
  defp insertInFile({:ok,content},path,insertionContent,insertionPoints,insertionPointTag) do
    ip0 = Enum.at(insertionPoints,0)
    ip1 = Enum.at(insertionPoints,1)
    cond do
      (StringUtil.trim(ip0) == "" or StringUtil.trim(ip1) == "") -> false
      (StringUtil.trim(insertionPointTag) == "") -> false
      (String.contains?(content,ip0) and String.contains?(content,ip1)) 
        -> makeReplacementInFile(path,content,insertionContent,ip0,ip1)
      (String.contains?(content,insertionPointTag)) 
        -> makeInsertionInFile(path,content,insertionContent,ip0,ip1,insertionPointTag)
      true -> false
    end
  end
  
  
  
  defp insertInFile({:error,_reason},_path,_contentInsert,_insertionPoints,_insertionPointTag) do
    #IO.puts(":error in insertInFile:")
    #IO.inspect(reason)
    false
  end
  
  
  
  defp removeFromFile(path,insertionPoints) do
    removeFromFile(File.read(path),path,insertionPoints)
  end
  
  
  
  defp removeFromFile({:ok,content},path,insertionPoints) do
    ip0 = Enum.at(insertionPoints,0)
    ip1 = Enum.at(insertionPoints,1)
    cond do
      (StringUtil.trim(ip0) == "" or StringUtil.trim(ip1) == "") -> false
      (!String.contains?(content,ip0) or !String.contains?(content,ip1)) -> true
      true -> makeRemoveFromFile(path,content,ip0,ip1)
    end
  end
  
  
  
  defp removeFromFile({:error,_reason},_path,_insertionPoints) do
    #IO.puts(":error in removeFromFile:")
    #IO.inspect(reason)
    false
  end
  
  
  
  defp makeReplacementInFile(path,content,insertionContent,ip0,ip1) do
    beforePart = content |> StringUtil.split("#{ip0}") |> Enum.at(0)
    afterPart = content |> StringUtil.split("#{ip1}") |> Enum.at(1)
    contentNew = "#{beforePart}#{ip0}\n#{insertionContent}\n#{ip1}#{afterPart}"
    writeToFile(path,contentNew)
  end
  
  
  
  defp makeInsertionInFile(path,content,insertionContent,ip0,ip1,insertionPointTag) do
    replacement = "#{ip0}\n#{insertionContent}\n#{ip1}\n#{insertionPointTag}"
    contentNew = StringUtil.replace(content,insertionPointTag,replacement)
    writeToFile(path,contentNew)
  end
  
  
  
  defp makeRemoveFromFile(path,content,ip0,ip1) do
    beforeParts = content |> StringUtil.split("#{ip0}")
    afterParts = cond do
      (String.contains?(content,"#{ip1}\n")) -> content |> StringUtil.split("#{ip1}\n")
      true -> content |> StringUtil.split("#{ip1}")
    end
    cond do
      (!(length(beforeParts) == 2)) -> false
      (!(length(afterParts) == 2)) -> false
      true -> writeToFile(path,"#{beforeParts |> Enum.at(0)}#{afterParts |> Enum.at(1)}")
    end
  end
  
  
  
end
