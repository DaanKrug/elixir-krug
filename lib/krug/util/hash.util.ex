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
  iex > Krug.HashUtil.hashPassword(password)
  $2b$10$y9nOBmx.kJV3juLBivaixuWMpIoB7ctGREqqrwvvgbqprY/BIRDX6
  ```
  """
  def hashPassword(password) do
    cond do
      (nil == password or password == "") -> ""
      true -> Bcrypt.Base.hash_password(password,Bcrypt.gen_salt(15,false)) #12 .. 31
    end
  end



  @doc """
  Compares a clean text string ```password``` whit a string ```hashed password```
  and verify if one matches another.
  
  If hashedPassword or password is nil/empty, return false. 

  ## Example

  ```elixir 
  iex > password = "123456"
  iex > hashedPassword = "$2b$10$y9nOBmx.kJV3juLBivaixuWMpIoB7ctGREqqrwvvgbqprY/BIRDX6"
  iex > Krug.HashUtil.passwordMatch(hashedPassword,password)
  true (or false if not matches)
  ```
  """  
  def passwordMatch(hashedPassword,password) do
    cond do
      (nil == hashedPassword or hashedPassword == "" or nil == password or password == "") -> false
      true -> handleVerify(Bcrypt.Base.checkpass_nif(:binary.bin_to_list(password),
                                                     :binary.bin_to_list(hashedPassword)))
    end
  end
  
  
  
  defp handleVerify(value) do
    (value == 0)
  end
  
  
  
end