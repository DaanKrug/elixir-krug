defmodule Krug.HashUtil do

  @moduledoc """
  Utilitary module to handle Bcrypt hashes. Useful for store and compare
  on more secure forms passwords.
  """



  @doc """
  Makes a ```password hash``` to improve a better security on storage.
  
  If nil/empty password received return a empty string.

  ## Example

  ```elixir 
  iex > password = "123456"
  iex > Krug.HashUtil.hash_password(password)
  $2b$10$y9nOBmx.kJV3juLBivaixuWMpIoB7ctGREqqrwvvgbqprY/BIRDX6
  ```
  """
  def hash_password(password) do
    cond do
      (nil == password or password == "") -> ""
      true -> Bcrypt.Base.hash_password(password,Bcrypt.gen_salt(15,false)) #12 .. 31
    end
  end



  @doc """
  Compares a clean text string ```password``` with a string ```hashed password```
  and verify if one matches another.
  
  If hashed_password or password is nil/empty, return false. 

  ## Example

  ```elixir 
  iex > password = "123456"
  iex > hashed_password = "$2b$10$y9nOBmx.kJV3juLBivaixuWMpIoB7ctGREqqrwvvgbqprY/BIRDX6"
  iex > Krug.HashUtil.password_match(hashed_password,password)
  true (or false if not matches)
  ```
  """  
  def password_match(hashed_password,password) do
    cond do
      (nil == hashed_password or hashed_password == "" or nil == password or password == "") -> false
      true -> handle_verify(Bcrypt.Base.checkpass_nif(:binary.bin_to_list(password),
                                                     :binary.bin_to_list(hashed_password)))
    end
  end
  
  
  
  defp handle_verify(value) do
    (value == 0)
  end
  
  
  
end