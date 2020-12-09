defmodule Krug.SanitizerUtil do

  @moduledoc """
  Utilitary secure module to provide methods that help
  whit data sanitization for validation, and some methods
  that result sanitized values.
  """

  alias Krug.StringUtil
  alias Krug.NumberUtil
  alias Krug.StructUtil
  
  
  
  @doc """
  Verify if an email contains only allowed chars to be present on email. 
  Apply lowercase before verification.
  
  - Allowed chars:
  ```elixir
  ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "-","+","@","_","."]
  ```
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.validateEmail(nil)
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateEmail("")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateEmail([])
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateEmail([""])
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateEmail("echo@ping%com")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateEmail("echo@ping$com")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateEmail("echo@ping.com")
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateEmail("echo@ping_com")
  true
  ```
  """
  def validateEmail(email) do 
    email = String.downcase("#{email}")
    emailSanitized = sanitizeAll(email,false,true,100,"email")
    emailSanitized != "" and emailSanitized == email
  end
  
  
  
  @doc """
  Verify if an url contains only chars allowed to be in a url.
  
  - Allowed chars:
  ```elixir
  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
   "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "(",")","*","-","+","%","@","_",".",",","$",":"," ",";","/","\\","?","=","&","[","]","{","}"]
  ```
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.validateUrl(nil)
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateUrl("")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateUrl(" ")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateUrl([])
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateUrl([""])
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateUrl("www.google.com")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateUrl("http://www.google.com")
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateUrl("https://www.google.com")
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validateUrl("https://www.echo|")
  false
  ```
  """
  def validateUrl(url) do
    urlSanitized = sanitizeAll(url,false,true,0,"url")
    cond do
      (urlSanitized == "") -> false 
      (urlSanitized != url) -> false
      (url |> String.slice(0..6) == "http://") -> true
      (url |> String.slice(0..7) == "https://") -> true
      true -> false
    end
  end
  
  
  
  @doc """
  Verify if an element of ```arrayValues``` is one of [nil,""," "].
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.hasEmpty(nil)
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasEmpty([])
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasEmpty([nil,1,2])
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasEmpty([3,4,""])
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasEmpty([8,7,9," "])
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasEmpty([[],%{},9,34,"$A"])
  false
  ```
  """
  def hasEmpty(arrayValues) do
    StructUtil.listContainsOne(arrayValues,[nil,""," "])
  end
  
  
  
  @doc """
  Verify if an element of ```arrayValues``` is < ```value```.
  
  If ```arrayValues``` is nil/empty return true.
  
  If ```value``` is not a number return false.
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.hasLessThan(nil,1)
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasLessThan([""],1)
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasLessThan([nil],1)
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasLessThan([1],nil)
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasLessThan([1],"")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasLessThan([1],"-1-1")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasLessThan([1],"10")
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasLessThan([1,0],1)
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasLessThan([1,0,-1],"-0.5")
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasLessThan([1,0,-1],"-0,5.5")
  false - * "-0,5.5" convert to -5.5
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasLessThan([1,0,-1],"-0,0.5")
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasLessThan([1,0,-1,[],nil,%{}],"-0,0.5")
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.hasLessThan([1,0,2,[],nil,%{}],"-0,0.5")
  false
  ```
  """
  def hasLessThan(arrayValues,value) do
    cond do
      (nil == arrayValues or length(arrayValues) == 0) -> true
      (NumberUtil.isNan(value)) -> false
      true -> Enum.min(arrayValues) < NumberUtil.toFloat(value)
    end
  end
  
  
  
  @doc """
  Generates a random string whit length ```size``` containing
  "A-z0-9" chars.
  ```elixir
  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
   "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "(",")","*","-","+","%","@","_",".",",","$",":"," ","/"]
  ```
  
  If ```size``` is not a number, set ```size``` to 10.
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandom(nil)
  "V@/)B*$fXG" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandom("")
  "NXd6oBJJK$" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandom(" ")
  "WñQcVCX1m(" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandom("10")
  "Y,nEWnty/t" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandom(20)
  "28ñHH5I2:$jcPCñ6kNk8" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandom("30")
  "7@sX$M%7gyy,58$_p@48_rRN%VjtVO" - random
  ```
  """
  def generateRandom(size) do
    size = cond do
      (NumberUtil.isNan(size)) -> 10
      true -> NumberUtil.toInteger(size)
    end
    generateRandomSeq(size,alphaNums(),"")
  end
  
  
  
  @doc """
  Generates a random string whit length ```size``` containing
  only numeric 0-9 chars.
  
  If ```size``` is not a number, set ```size``` to 10.
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandomOnlyNum(nil)
  "8842631571" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandomOnlyNum("")
  "3983415257" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandomOnlyNum(" ")
  "5367142216" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandomOnlyNum(10)
  "1519486235" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandomOnlyNum("20")
  "45396319754971833184" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandomOnlyNum(30)
  "845951826982685147272442547731" - random
  ```
  """
  def generateRandomOnlyNum(size) do
    size = cond do
      (NumberUtil.isNan(size)) -> 10
      true -> NumberUtil.toInteger(size)
    end
    generateRandomSeq(size,onlyNums(),"")
  end
  
  
  
  @doc """
  Generates a random string whit length ```size``` containing
  only allowed chars to be used in file names.
  
  If ```size``` is not a number, set ```size``` to 10.
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandomFileName(nil)
  "2mi1k281XY" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandomFileName("")
  "1xdsohbWBs" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandomFileName(" ")
  "3orpWPvnfg" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandomFileName(10)
  "T29p17Gbqi" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandomFileName("20")
  "Ry7JFypiFVl2z8jDhsg1" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generateRandomFileName(30)
  "OxC5DTSmih3BG5uj7KmK1XgWDvMBe3" - random
  ```
  """
  def generateRandomFileName(size) do
    size = cond do
      (NumberUtil.isNan(size)) -> 10
      true -> NumberUtil.toInteger(size)
    end
    generateRandomSeq(size,fileNameChars(),"")
  end
  
  
  
  @doc """
  Convert received value to a string, and replace some special chars to normalized chars.
  
  - Special chars:
  ```elixir  
  ["ã","á","à","â","ä","å","æ",
   "é","è","ê","ë",
   "í","ì","î","ï",
   "õ","ó","ò","ô","ö","ø","œ","ð",
   "ú","ù","û","ü","µ",
   "ç","š","ž","ß","ñ","ý","ÿ",
   "Ã","Á","À","Â","Ä","Å","Æ",
   "É","È","Ê","Ë",
   "Í","Ì","Î","Ï",
   "Õ","Ó","Ò","Ô","Ö","Ø","Œ",
   "Ú","Ù","Û","Ü",
   "Ç","Š","Ž","Ÿ","¥","Ý","Ð","Ñ"]
  ```
  
  - Normalized chars:
  ```elixir
  ["a","a","a","a","a","a","a",
   "e","e","e","e",
   "i","i","i","i",
   "o","o","o","o","o","o","o","o",
   "u","u","u","u","u",
   "c","s","z","s","n","y","y",
   "A","A","A","A","A","A","A",
   "E","E","E","E",
   "I","I","I","I",
   "O","O","O","O","O","O","O",
   "U","U","U","U",
   "C","S","Z","Y","Y","Y","D","N"]
  ```
  
  ## Example
  
  ```elixir 
  iex > Krug.SanitizerUtil.translate("éèêëÇŠŽŸ¥ÝÐÑ")
  "eeeeCSZYYYDN"
  ```
  """
  def translate(input) do
    translateFromArrayChars(input,strangeChars(),translatedChars(),0)
  end
  
  
  
  @doc """
  Convert received value to a string, make some validations of forbidden content.
  
  If forbidden content are finded, return nil. Otherwise return received value 
  making some unobfscating substution operations.
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize("echo <script echo")
  nil
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize("echo < script echo")
  nil
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize("echo script> echo")
  nil
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize("echo script > echo")
  nil
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize(echoscript>echo)
  nil
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize("echoscriptecho")
  "echoscriptecho"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize("echo script echo")
  "echo script echo"
  ```
  """
  def sanitize(input) do
    input = StringUtil.replace(input,"quirbula",",") 
    input = StringUtil.replace(input,"xcrept ","select ")
    input = StringUtil.replace(input,"xoo ","and ")
    input = StringUtil.replace(input,"yoo ","or ")
    input = StringUtil.replace(input,"x43re ","where ")
    input = StringUtil.replace(input,"despint","distinct")
    input = StringUtil.replace(input,"xstrike ","like ")
    input = StringUtil.replace(input,"quaspa","'")
    input = StringUtil.replace(input,"description","dessccrriippttion")
    cond do
      (StringUtil.containsOneElementOfArray(input,forbidden())) -> nil
      true -> StringUtil.replace(input,"dessccrriippttion","description")
    end
  end
  
  
  
  @doc """
  Convert received value to a string, make some validations of forbidden content and allowed chars.
  If forbidden content or not allowed chars are finded, return empty string for 
  not numeric input values and "0" for numeric values.
  
  If ```sanitizeInput``` received as true, then call additionally methods 
  to sanitize the value as comming from a html input field 
  (type: text,number and all others except textarea).
  
  ```validChars``` should be a string whit the valid chars aceppted, separated
  by comma (ex.: "a,b,c,d,4") or a string that matches whit a predefined values name.
  If ```validChars``` is nil/empty default value "A-z0-9" is used if
  ```isNumber``` = false otherwise if is a number the "0-9" value used by default.
  
  Named ```validChars``` predefined values and respective chars:
  
  - "A-z0-9"
  ```elixir  
  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
   "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "(",")","*","-","+","%","@","_",".",",","$",":"," ","/"]
  ``` 
  
  - "A-z0-9Name"
  ```elixir 
  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
   "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "-",","," "]
  ```
     
  - "A-z0-9|"
    All "A-z0-9" more "|"
    
  - "0-9"
  ```elixir 
  ["-",".","0","1","2","3","4","5","6","7","8","9"]
  ```
    
  - "A-z"
  ```elixir 
  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
   "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
   "(",")","*","-","+","%","@","_",".",",","$",":"," ","/"]
  ```
     
  - "a-z"
  ```elixir 
  ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
   "(",")","*","-","+","%","@","_",".",",","$",":"," ","/"]
  ```
     
  - "A-Z"
  ```elixir 
  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
   "(",")","*","-","+","%","@","_",".",",","$",":"," ","/"]
  ```
     
  - "DATE_SLASH"
  ```elixir 
  [":","/"," ","0","1","2","3","4","5","6","7","8","9"]
  ```
  
  - "DATE_SQL"
  ```elixir 
  [":","-"," ","0","1","2","3","4","5","6","7","8","9"]
  ```
    
  - "email"
  ```elixir 
  ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "-","+","@","_","."]
  ```
     
  - "password"
  ```elixir 
  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
   "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "*","+","%","@","_",".",",","$",":","-"]
  ```
     
  - "url"
  ```elixir 
  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
   "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "(",")","*","-","+","%","@","_",".",",","$",":"," ",";","/","\\","?","=","&","[","]","{","}"]
  ``` 
     
  - "hex"
  ```elixir 
  ["A","B","C","D","E","F","a","b","c","d","e","f","0","1","2","3","4","5","6","7","8","9"]
  ```
    
  - "filename"
  ```elixir 
  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
   "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "_","."]
  ``` 
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeAll("09 8778 987",false,true,250,"0-9")
  ""
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeAll("098778987",false,true,250,"0-9")
  "098778987"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeAll("09 8778 987",true,true,250,"0-9")
  "0"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeAll("098778987",true,true,250,"0-9")
  "098778987"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeAll("09 8778 987 ABCDEF ",false,true,250,"A-z")
  ""
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeAll("09 8778 987 ABCDEF ",false,true,250,"0-9")
  ""
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeAll("09 8778 987 ABCDEF ",false,true,250,"A-z0-9")
  "09 8778 987 ABCDEF"
  ```
  """
  def sanitizeAll(input,isNumber,sanitizeInput,maxSize,validChars) do
    input = "#{input}"
    forbidden = StringUtil.containsOneElementOfArray(input,forbidden())
    cond do
      (isNumber and forbidden) -> "0"
      (forbidden) -> ""
      (sanitizeInput) -> sanitizeInput(input,isNumber,maxSize,validChars)
      true -> StringUtil.trim(input)
    end
  end
  
  
  
  @doc """
  Sanitizes a file name to escape not allowed chars
  and force the use of file name whit length <= maxSize. 
  
  If any not allowed char is found, or the file name length > maxSize,
  the value received is ignored and a new random name is generated 
  whit the valid chars whit size = maxSize and return.
  
  If maxSize is nil or maxSize <= 0, maxSize for generate a ramdom string
  name receive 10. (Then the file name has no limit of chars, if contains only
  valid chars).
  
  Allowed chars:
  ```elixir
  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
   "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "_","."]
  ```

  ## Examples

  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeFileName(nil,10)
  "rOufHwKL7a" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeFileName("",10)
  "WQskDae0ZP" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeFileName(" ",10)
  "htlp9cKxHC" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeFileName(" ",10)
  "rOufHwKL7a" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeFileName(" afdd#%%{}8989nfdfdd@",10)
  "ts44e22BuP" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeFileName("afdd#%%{}8989nfdfdd@",100)
  "Jnn7nZICOwuuOXou4q7EBqNVtPHcYgvjh7dORJczzIlPMI7Yr5N96miqHv8gV88KTc2QOaW1yG9FJRsqeRMCKtVTbjepPKQE3whd" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeFileName("Aabcde_fg.6712.89_as",10)
  "ts44e22BuP" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeFileName("Aabcde_fg.6712.89_as",19)
  "ts44e22BuP" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeFileName("Aabcde_fg.6712.89_as",20)
  "Aabcde_fg.6712.89_as"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitizeFileName("Aabcde_fg.6712.89_as",50)
  "Aabcde_fg.6712.89_as"
  ```
  """
  def sanitizeFileName(name,maxSize) do
    maxSize2 = cond do
      (nil == maxSize or !(maxSize > 0)) -> 10
      true -> maxSize
    end
    name = sanitizeInput(name,false,maxSize,"filename")
    cond do
      (String.length(name) == 0) -> generateRandomFileName(maxSize2)
      true -> name
    end
  end
  
  
  
  @doc """
  Return the valid numeric chars array.

  ## Example

  ```elixir 
  iex > Krug.SanitizerUtil.nums()
  ["-",".","0","1","2","3","4","5","6","7","8","9"]
  ```
  """
  def nums() do
    ["-",".","0","1","2","3","4","5","6","7","8","9"]
  end
  
  
  
  @doc """
  Return the valid numbers chars array.

  ## Example

  ```elixir 
  iex > Krug.SanitizerUtil.onlyNums()
  ["0","1","2","3","4","5","6","7","8","9"]
  ```
  """
  def onlyNums() do
    ["0","1","2","3","4","5","6","7","8","9"]
  end
  
  
  
  @doc """
  Return the valid money format chars array.

  ## Example

  ```elixir 
  iex > Krug.SanitizerUtil.moneyChars()
  [",","0","1","2","3","4","5","6","7","8","9"]
  ```
  """
  def moneyChars() do
    [",","0","1","2","3","4","5","6","7","8","9"]
  end
  
  
  
  @doc """
  Return the valid email chars array.

  ## Example

  ```elixir 
  iex > Krug.SanitizerUtil.emailChars()
  ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "-","+","@","_","."]
  ```
  """
  def emailChars() do
  	["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
     "0","1","2","3","4","5","6","7","8","9",
     "-","+","@","_","."]
  end
  
  
  
  defp sanitizeInput(input,isNumber,maxSize,validChars) do
    originalInput = StringUtil.trim(input)
    translated = translate(originalInput)
    size = length(String.graphemes(translated))
    cond do
      (isNumber and originalInput == "") -> "0"
      (originalInput == "") -> ""
      (isNumber and maxSize > 0 and (size > maxSize or size == 0)) -> "0"
      (maxSize > 0 and (size > maxSize or size == 0)) -> ""
      true -> sanitizeByValiChars(originalInput,translated,validChars,isNumber)
    end
  end
  
  
  
  defp sanitizeByValiChars(input,translated,validChars,isNumber) do
    enabledChars = getValidCharsForSanitizeInput(validChars,isNumber)
    cond do
      (allCharsValidsForPosition(enabledChars,String.graphemes(translated),isNumber,0)) -> input
      isNumber -> "0"
      true -> ""
    end
  end
  
  
  
  defp allCharsValidsForPosition(enabledChars,translatedArr,isNumber,position) do
    cond do
      (length(translatedArr) <= position) -> true
      (isNumber and position > 0 and Enum.at(translatedArr,position) == "-") -> false
      (!StructUtil.listContains(enabledChars,Enum.at(translatedArr,position))) -> false
      true -> allCharsValidsForPosition(enabledChars,translatedArr,isNumber,position + 1)
    end
  end
  
  
  
  defp getValidCharsForSanitizeInput(validChars,isNumber) do
    cond do
      (nil == validChars and isNumber) -> nums()
      (nil == validChars or validChars == "A-z0-9") -> alphaNums()
      (validChars == "A-z0-9Name") -> alphaNumsName()
      (validChars == "A-z0-9|") -> alphaNumsPipe()
      (validChars == "0-9") -> nums()
      (validChars == "A-z") -> alphas()
      (validChars == "a-z") -> alphaLowers()
      (validChars == "A-Z") -> alphaUppers()
      (validChars == "DATE_SLASH") -> dateSlash()
      (validChars == "DATE_SQL") -> dateSql()
      (validChars == "email") -> emailChars()
      (validChars == "password") -> passwordChars()
      (validChars == "url") -> urlChars()
      (validChars == "hex") -> hexChars()
      (validChars == "filename") -> fileChars()
      true -> splitToArrayAndClearEmpty(validChars,[],[],0)
    end
  end
  
  
  
  defp splitToArrayAndClearEmpty(validChars,arr,clearArr,position) do
    cond do
      (StringUtil.trim(validChars) == "") -> alphaNums()
      (length(arr) == 0) 
        -> splitToArrayAndClearEmpty(validChars,StringUtil.split(arr,","),clearArr,position)
      (length(arr) <= position) -> clearArr
      true -> splitToArrayAndClearEmpty(validChars,arr,addToArrIfNotEmpty(clearArr,Enum.at(arr,position)),
                                        position + 1)
    end
  end
  
  
  
  defp addToArrIfNotEmpty(arr,value) do
    cond do
      (nil == value or StringUtil.trim(value) == "") -> arr
      true -> [value | arr]
    end
  end
  
  
  
  defp translateFromArrayChars(input,arr1,arr2,position) do
    cond do
      (length(arr1) <= position) -> input
      true -> translateFromArrayChars(StringUtil.replace(input,Enum.at(arr1,position),
                                      Enum.at(arr2,position)),arr1,arr2,position + 1)
    end
  end
  
  
  
  defp generateRandomSeq(size,arr,seq) do
    position = arr |> length() |> :rand.uniform()
    char = arr |> Enum.at(position) |> StringUtil.trim()
    cond do
      (String.length(seq) == size) -> seq
      true -> generateRandomSeq(size,arr,"#{seq}#{char}")
    end
  end
  
  
  
  defp forbidden() do
    ["< script","<script","script>","script >"]
  end
  
  
  
  defp strangeChars() do
    ["ã","á","à","â","ä","å","æ",
     "é","è","ê","ë",
     "í","ì","î","ï",
     "õ","ó","ò","ô","ö","ø","œ","ð",
     "ú","ù","û","ü","µ",
     "ç","š","ž","ß","ñ","ý","ÿ",
     "Ã","Á","À","Â","Ä","Å","Æ",
     "É","È","Ê","Ë",
     "Í","Ì","Î","Ï",
     "Õ","Ó","Ò","Ô","Ö","Ø","Œ",
     "Ú","Ù","Û","Ü",
     "Ç","Š","Ž","Ÿ","¥","Ý","Ð","Ñ"]
  end
  
  
  
  defp translatedChars() do
    ["a","a","a","a","a","a","a",
     "e","e","e","e",
     "i","i","i","i",
     "o","o","o","o","o","o","o","o",
     "u","u","u","u","u",
     "c","s","z","s","n","y","y",
     "A","A","A","A","A","A","A",
     "E","E","E","E",
     "I","I","I","I",
     "O","O","O","O","O","O","O",
     "U","U","U","U",
     "C","S","Z","Y","Y","Y","D","N"]
  end
  
  
  
  defp alphas() do
    ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
     "(",")","*","-","+","%","@","_",".",",","$",":"," ","/"]
  end
  
  
  
  defp alphaLowers() do
  	["a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
     "(",")","*","-","+","%","@","_",".",",","$",":"," ","/"]
  end
  
  
  
  defp alphaUppers() do
    ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "(",")","*","-","+","%","@","_",".",",","$",":"," ","/"]
  end
  
  
  
  defp alphaNums() do
  	["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
     "0","1","2","3","4","5","6","7","8","9",
     "(",")","*","-","+","%","@","_",".",",","$",":"," ","/"]
  end
  
  
  
  defp alphaNumsName() do
  	["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
     "0","1","2","3","4","5","6","7","8","9",
     "-",","," "]
  end
  
  
  
  defp urlChars() do
  	["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
     "0","1","2","3","4","5","6","7","8","9",
     "(",")","*","-","+","%","@","_",".",",","$",":"," ",";","/","\\","?","=","&","[","]","{","}"]
  end
  
  
  
  defp passwordChars() do
    ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
     "0","1","2","3","4","5","6","7","8","9",
     "*","+","%","@","_",".",",","$",":","-"]
  end
  
  
  
  defp alphaNumsPipe() do
    [ "|" | alphaNums()]
  end
  
  
  
  defp hexChars() do
    ["A","B","C","D","E","F","a","b","c","d","e","f","0","1","2","3","4","5","6","7","8","9"]
  end
  
  
  
  defp fileChars() do
    ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
     "0","1","2","3","4","5","6","7","8","9",
     "_","."]
  end
  
  
  
  defp fileNameChars() do
    ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
     "0","1","2","3","4","5","6","7","8","9"]
  end
  
  
  
  defp dateSlash() do
    [":","/"," ","0","1","2","3","4","5","6","7","8","9"]
  end
  
  
  
  defp dateSql() do
    [":","-"," ","0","1","2","3","4","5","6","7","8","9"]
  end
  
  
  
end