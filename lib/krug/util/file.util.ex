defmodule Krug.FileUtil do

  @moduledoc """
  Utilitary module to handle files and directories.
  """
  
  alias Krug.StringUtil
  
  
  
  @doc """
  Creates a new directory with name specified. 
  
  If already exists a directory with this name, only preserve these directory. 
  
  If exists a file with this name try delete the file before create a new directory.
  Return false if this file cannot be deleted.
  
  Finally change permissions of these dir to 777 (chmod), in success case.
  
  ## Example

  ```elixir 
  iex > Krug.FileUtil.create_dir(path)
  true (or false if fail)
  ```
  """
  def create_dir(path) do
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
  iex > Krug.FileUtil.copy_dir(from_dir,to_dir)
  true (or false if fail)
  ```
  """
  def copy_dir(from_dir,to_dir) do
    result = cond do
      (!(File.exists?(from_dir)) or !(File.dir?(from_dir))) -> {:error, :enotdir}
      (!(File.exists?(to_dir)) or !(File.dir?(to_dir))) -> {:error, :enotdir}
      true -> File.cp_r(from_dir,to_dir)
    end
    cond do
      (:ok != result |> Tuple.to_list() |> Enum.at(0)) -> false
      true -> chmod(to_dir,0o777)
    end
  end
  
  
  
  @doc """
  Delete a directory with specified name. 
  
  Return false if the directory don't exists and parameter ignore_if_dont_exists is false/don't received.
  
  If the name is a file and not a diectory, return false.
  
  ## Examples

  ```elixir 
  iex > Krug.FileUtil.drop_dir(path)
  true (or false if fail)
  ```
  ```elixir 
  iex > Krug.FileUtil.drop_dir(path,true)
  true (or false if fail)
  ```
  """
  def drop_dir(path,ignore_if_dont_exists \\ false) do
    result = cond do
      (ignore_if_dont_exists and !(File.exists?(path))) -> {:ok, "OK"}
      (!(File.exists?(path)) or !(File.dir?(path))) -> {:error, :enotdir}
      true -> File.rm_rf(path)
    end
    (:ok == result |> Tuple.to_list() |> Enum.at(0))
  end
  
  
  
  @doc """
  Copy a file to another file. 
  
  Return false if a destination file
  already exists and the parameter ignore_if_exists don't was received as true.
  
  Finally change permissions of the destination file to 777 (chmod), in success case.

  ## Examples

  ```elixir 
  iex > Krug.FileUtil.copy_file(from_file,to_file)
  true (or false if fail)
  ```
  ```elixir 
  iex > Krug.FileUtil.copy_file(from_file,to_file,true)
  true (or false if fail)
  ```
  """
  def copy_file(from_file,to_file,ignore_if_exists \\ true) do
    result = cond do
      (!(File.exists?(from_file))) -> {:error, :enoent}
      (!ignore_if_exists and File.exists?(to_file)) -> {:error, :eexist}
      true -> File.copy(from_file,to_file)
    end
    cond do
      (:ok != result |> Tuple.to_list() |> Enum.at(0)) -> false
      true -> chmod(to_file,0o777)
    end
  end
  
  
  
  @doc """
  Delete a file. 
  
  Return false if the file don't exists and
  the parameter ignore_if_dont_exists don't was received as true.
  
  If file is a directory, return false.
  
  ## Examples

  ```elixir 
  iex > Krug.FileUtil.drop_file(path)
  true (or false if fail)
  ```
  ```elixir 
  iex > Krug.FileUtil.drop_file(path,true)
  true (or false if fail)
  ```
  """
  def drop_file(path,ignore_if_dont_exists \\ false) do
    cond do
      (ignore_if_dont_exists and !(File.exists?(path))) -> true
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
  iex > Krug.FileUtil.read_file(path)
  file content (or nil)
  ```
  """
  def read_file(path) do
    cond do
      (!(File.exists?(path)) or File.dir?(path)) -> nil
      true -> File.read(path) |> read_content()
    end
  end
  
  
  
  @doc """
  Change the file/directory permissions. 
  
  Return true if the file/directory exists
  and the permissions are correctly changed.
  
  Permission should be initiate with ```0o``` chars 
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
  
  If the parameter insertion_points and parameter insertion_point_tag are received,
  the content original is preserved and content received is inserted
  before of insertion_point_tag and beetwen insertion_points[0] and insertion_points[1].
  (insertion_points are write in this moment, and could be used to remove this content later).
  
  If insertion_point_tag is received and don't exists in file, return false.
  
  Accept only file extensions: 
  ```elixir
  ["sql","txt","html","xml","webmanifest","ts","js","ex","exs","sh","json","ret",
     "pdf","ppt","pptx","doc","docx","xls","xlsx","php","erl","gif","jpeg","jpg","png","bmp"]
  ```
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
  def write(path,content,insertion_points \\ [],insertion_point_tag \\ nil) do
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
      (!(Enum.member?(valid_extensions(),ext))) -> false
      (nil != insertion_points and length(insertion_points) == 2 
        and nil != insertion_point_tag and StringUtil.trim(insertion_point_tag) != "") 
          -> insert_in_file(path,content,insertion_points,insertion_point_tag) 
      true -> write_to_file(path,content)
    end
  end
  
  
  
  @doc """
  Remove the content of a file if that is located between insertion_points[0] and insertion_points[1].
  The insertion_points are removed too.
  
  Fail if the file don't exists, is a directory, operation fail, or the 
  insertion_points[0] or insertion_points[1] don't exists in file.
  
  Accept only file extensions: 
  ```elixir
  ["sql","txt","html","xml","webmanifest","ts","js","ex","exs","sh","json","ret",
     "pdf","ppt","pptx","doc","docx","xls","xlsx","php","erl","gif","jpeg","jpg","png","bmp"]
  ```
  will fail for other file extensions.

  ## Example

  ```elixir 
  iex > Krug.FileUtil.remove(path,["markerBegin","markerEnd"])
  true (or false if fail)
  ```
  """
  def remove(path,insertion_points) do
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
      (!(Enum.member?(valid_extensions(),ext))) -> false
      (nil != insertion_points and length(insertion_points) == 2) -> remove_from_file(path,insertion_points) 
      true -> false
    end
  end
  
  
  
  @doc """
  Replaces all ocurrences of a ```search_by``` parameter value 
  by ```replace_to``` parameter value in the file.
  
  Fail if the file is directory or don't exists.
  
  Accept only file extensions: 
  ```elixir
  ["sql","txt","html","xml","webmanifest","ts","js","ex","exs","sh","json","ret",
     "pdf","ppt","pptx","doc","docx","xls","xlsx","php","erl","gif","jpeg","jpg","png","bmp"]
  ```
  will fail for other file extensions.

  ## Example

  ```elixir 
  iex > Krug.FileUtil.replace_in_file(path,"AA","BB")
  true (or false if fail)
  ```
  """
  def replace_in_file(path,search_by,replace_to) do
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
      (!(Enum.member?(valid_extensions(),ext))) -> false
      true -> replace_in_file(File.read(path),path,search_by,replace_to)
    end
  end
  
  
  
  @doc """
  Creates a zip from a directory with same name directory name plus ".zip" extension. 
  This function uses ```File.ls!``` to obtain directory files and because that dont is recursive.
  
  If already exists a zip file with this name, or the ```path``` directory don't exists
  or isn't a directory, then return false. Otherwise tries create a zip and return
  true if succeed.
  
  If ```drop_if_exists``` parameter received and equals "true" boolean, then
  tries delete the equivalent zipped dir if these already exists before try zip.
  
  Finally change permissions of these zip dir to 777 (chmod), in success case.
  
  ## Example

  ```elixir 
  iex > Krug.FileUtil.zip_dir(path)
  true (or false if fail)
  ```
  """
  @doc since: "0.4.24"
  def zip_dir(path,drop_if_exists \\ false) do
    path_zip = "#{path}.zip"
  	cond do
  	  (!File.exists?(path) or !File.dir?(path)) -> false
  	  (File.exists?(path_zip) and drop_if_exists) -> drop_zip_and_retry(path,path_zip)
      (File.exists?(path_zip)) -> false
      true -> try_zip_dir(path,path_zip)
    end
  end
  
  
  
  defp try_zip_dir(path,path_zip) do
    files = File.ls!(path)
              |> Enum.map(fn(filename) -> Path.join(path,filename) end)
              |> Enum.map(&String.to_charlist/1)
    :zip.create(String.to_charlist(path_zip),files)
    cond do
      (File.exists?(path_zip)) -> chmod(path_zip,0o777)
      true -> false
    end
  end
  
  
  
  defp drop_zip_and_retry(path,path_zip) do
    drop_file(path_zip)
    zip_dir(path,false)
  end
  
  
  
  defp read_content({:ok, binary}) do
    cond do
      (nil == binary) -> nil
      true -> "#{binary}" |> StringUtil.trim()
    end
  end
  
  
  
  defp read_content({:error, _reason}) do
    #IO.puts(":error in read_content:")
    #IO.inspect(reason)
    nil
  end
  
  
  
  defp write_to_file(path,content) do  
    cond do
      (!(drop(path))) -> false
      (!(open_and_write(File.open(path,[:write]),path,content))) -> false
      true -> true
    end
  end
  
  
  
  defp open_and_write({:ok, file},path,content) do
    IO.write(file,content)
    File.close(file)
    chmod(path,0o777)
    true
  end
  
  
  
  defp open_and_write({:error,_reason},_path,_content) do
    #IO.puts(":error in open_and_write:")
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
  
  
  
  defp valid_extensions() do
    ["sql","txt","html","xml","webmanifest","ts","js","ex","exs","sh","json","ret",
     "pdf","ppt","pptx","doc","docx","xls","xlsx","php","erl","gif","jpeg","jpg","png","bmp"]
  end
  
  
  
  defp replace_in_file({:ok,content},path,search_by,replace_to) do
    content_new = cond do
      (search_by |> StringUtil.trim() == "") -> nil
      (replace_to |> StringUtil.trim() == "") -> nil
      true -> content |> StringUtil.replace(search_by,replace_to)
    end
    cond do
      (content_new == nil) -> false
      true -> write_to_file(path,content_new)
    end
  end
  
  
  
  defp replace_in_file({:error,_reason},_path,_search_by,_replace_to) do
    #IO.puts(":error in replace_in_file:")
    #IO.inspect(reason)
    false
  end
  
  
  
  defp insert_in_file(path,content_insert,insertion_points,insertion_point_tag) do
    insert_in_file(File.read(path),path,content_insert,insertion_points,insertion_point_tag)
  end
  
  
  
  defp insert_in_file({:ok,content},path,insertion_content,insertion_points,insertion_point_tag) do
    ip0 = Enum.at(insertion_points,0)
    ip1 = Enum.at(insertion_points,1)
    cond do
      (StringUtil.trim(ip0) == "" or StringUtil.trim(ip1) == "") -> false
      (StringUtil.trim(insertion_point_tag) == "") -> false
      (String.contains?(content,ip0) and String.contains?(content,ip1)) 
        -> make_replacement_in_file(path,content,insertion_content,ip0,ip1)
      (String.contains?(content,insertion_point_tag)) 
        -> make_insertion_in_file(path,content,insertion_content,ip0,ip1,insertion_point_tag)
      true -> false
    end
  end
  
  
  
  defp insert_in_file({:error,_reason},_path,_content_insert,_insertion_points,_insertion_point_tag) do
    #IO.puts(":error in insert_in_file:")
    #IO.inspect(reason)
    false
  end
  
  
  
  defp remove_from_file(path,insertion_points) do
    remove_from_file(File.read(path),path,insertion_points)
  end
  
  
  
  defp remove_from_file({:ok,content},path,insertion_points) do
    ip0 = Enum.at(insertion_points,0)
    ip1 = Enum.at(insertion_points,1)
    cond do
      (StringUtil.trim(ip0) == "" or StringUtil.trim(ip1) == "") -> false
      (!String.contains?(content,ip0) or !String.contains?(content,ip1)) -> true
      true -> make_remove_from_file(path,content,ip0,ip1)
    end
  end
  
  
  
  defp remove_from_file({:error,_reason},_path,_insertion_points) do
    #IO.puts(":error in remove_from_file:")
    #IO.inspect(reason)
    false
  end
  
  
  
  defp make_replacement_in_file(path,content,insertion_content,ip0,ip1) do
    before_part = content |> StringUtil.split("#{ip0}") |> Enum.at(0)
    after_part = content |> StringUtil.split("#{ip1}") |> Enum.at(1)
    content_new = "#{before_part}#{ip0}\n#{insertion_content}\n#{ip1}#{after_part}"
    write_to_file(path,content_new)
  end
  
  
  
  defp make_insertion_in_file(path,content,insertion_content,ip0,ip1,insertion_point_tag) do
    replacement = "#{ip0}\n#{insertion_content}\n#{ip1}\n#{insertion_point_tag}"
    content_new = StringUtil.replace(content,insertion_point_tag,replacement)
    write_to_file(path,content_new)
  end
  
  
  
  defp make_remove_from_file(path,content,ip0,ip1) do
    before_parts = content |> StringUtil.split("#{ip0}")
    after_parts = cond do
      (String.contains?(content,"#{ip1}\n")) -> content |> StringUtil.split("#{ip1}\n")
      true -> content |> StringUtil.split("#{ip1}")
    end
    cond do
      (!(length(before_parts) == 2)) -> false
      (!(length(after_parts) == 2)) -> false
      true -> write_to_file(path,"#{before_parts |> Enum.at(0)}#{after_parts |> Enum.at(1)}")
    end
  end
  
  
  
end
