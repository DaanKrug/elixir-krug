defmodule Krug.SanitizerUtil do

  @moduledoc """
  Utilitary secure module to provide methods that help
  with data sanitization for validation, and some methods
  that result sanitized values.
  """

  alias Krug.StringUtil
  alias Krug.NumberUtil
  alias Krug.StructUtil
  
  
  @forbidden_sql [
    "--","insert ","delete ","drop ","truncate ","alter ",
    "update ","cascade ","order by ","group by ","union ",
    "having ","join ","limit ",
    "min(","min (",
    "max(","max (",
    "avg(","avg (",
    "sum(","sum (",
    "coalesce(","coalesce (",
    "distinct(","distinct (",
    "concat(","concat (",
    "group_concat(","group_concat (",
    "grant ","revoke ","commit ","rollback ",
    "../"
  ]
  
  @forbidden [
    "< script","<script","script>","script >",
    "</script","< /script","</ script", "< / script",
    "<body","< body",
    "< ?","<?","? >","?>",
    "../","<%","< %","%>","% >",
    "onerror=","onerror =",
    "onclick=","onclick =",
    "onload=","onload =",
    "alert(","alert (",
    "prompt(","prompt (",
    "eval(","eval (",
    "settimeout(","settimeout (",
    "setinterval(","setinterval (",
    "innerhtml=","innerhtml ="
  ]
  
  @strange_chars [
    "ã","á","à","â","ä","å","æ",
    "é","è","ê","ë",
    "í","ì","î","ï",
    "õ","ó","ò","ô","ö","ø","œ","ð",
    "ũ","ú","ù","û","ü","µ",
    "ç","š","ž","ß","ñ","ý","ÿ",
    "Ã","Á","À","Â","Ä","Å","Æ",
    "É","È","Ê","Ë",
    "Í","Ì","Î","Ï",
    "Õ","Ó","Ò","Ô","Ö","Ø","Œ",
    "Ũ","Ú","Ù","Û","Ü",
    "Ç","Š","Ž","Ÿ","¥","Ý","Ð","Ñ"
  ]
  
  @translated_chars [
    "a","a","a","a","a","a","a",
    "e","e","e","e",
    "i","i","i","i",
    "o","o","o","o","o","o","o","o",
    "u","u","u","u","u","u",
    "c","s","z","s","n","y","y",
    "A","A","A","A","A","A","A",
    "E","E","E","E",
    "I","I","I","I",
    "O","O","O","O","O","O","O",
    "U","U","U","U","U",
    "C","S","Z","Y","Y","Y","D","N"
  ]
  
  @alpha_nums [
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
    "0","1","2","3","4","5","6","7","8","9",
    "(",")","*","-","+","%","@","_",".",",","$",":"," ","/","º","ª","?","!"
  ]
  
  @alpha_nums_random [
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
    "0","1","2","3","4","5","6","7","8","9",
    "(",")","+","@","_",".",",","$",":","/","?","!"
  ]
  
  @nums [
    "-",".","0","1","2","3","4","5","6","7","8","9"
  ]
  
  
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
  iex > Krug.SanitizerUtil.validate_email(nil)
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_email("")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_email([])
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_email([""])
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_email("echo@ping%com")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_email("echo@ping$com")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_email("echo@ping.com")
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_email("echo@ping_com")
  true
  ```
  """
  def validate_email(email) do 
    email = String.downcase("#{email}")
    sanitized_email = sanitize_all(email,false,true,100,"email")
    sanitized_email != "" and sanitized_email == email
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
  iex > Krug.SanitizerUtil.validate_url(nil)
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_url("")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_url(" ")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_url([])
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_url([""])
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_url("www.google.com")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_url("http://www.google.com")
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_url("https://www.google.com")
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.validate_url("https://www.echo|")
  false
  ```
  """
  def validate_url(url) do
    sanitized_url = sanitize_all(url,false,true,0,"url")
    cond do
      (sanitized_url == "") -> false 
      (sanitized_url != url) -> false
      (url |> StringUtil.slice(0,6) == "http://") -> true
      (url |> StringUtil.slice(0,7) == "https://") -> true
      true -> false
    end
  end
  
  
  
  @doc """
  Verify if an element of ```array_values``` is one of [nil,""," "].
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.has_empty(nil)
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.has_empty([])
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.has_empty([nil,1,2])
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.has_empty([3,4,""])
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.has_empty([8,7,9," "])
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.has_empty([[],%{},9,34,"$A"])
  false
  ```
  """
  def has_empty(array_values) do
    StructUtil.list_contains_one_of(array_values,[nil,""," "])
  end
  
  
  
  @doc """
  Verify if an element of ```array_values``` is < ```value```.
  
  If ```array_values``` is nil/empty return true.
  
  If ```value``` is not a number return false.
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.array_has_one_less_than(nil,1)
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.array_has_one_less_than([""],1)
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.array_has_one_less_than([nil],1)
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.array_has_one_less_than([1],nil)
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.array_has_one_less_than([1],"")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.array_has_one_less_than([1],"-1-1")
  false
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.array_has_one_less_than([1],"10")
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.array_has_one_less_than([1,0],1)
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.array_has_one_less_than([1,0,-1],"-0.5")
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.array_has_one_less_than([1,0,-1],"-0,5.5")
  false - * "-0,5.5" convert to -5.5
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.array_has_one_less_than([1,0,-1],"-0,0.5")
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.array_has_one_less_than([1,0,-1,[],nil,%{}],"-0,0.5")
  true
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.array_has_one_less_than([1,0,2,[],nil,%{}],"-0,0.5")
  false
  ```
  """
  def array_has_one_less_than(array_values,value) do
    cond do
      (nil == array_values or Enum.empty?(array_values)) -> true
      (NumberUtil.is_nan(value)) -> false
      true -> Enum.min(array_values) < NumberUtil.to_float(value)
    end
  end
  
  
  
  @doc """
  Generates a random string with length ```size``` containing "A-z0-9" chars.
  ```elixir
  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
   "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "(",")","*","-","+","%","@","_",".",",","$",":"," ","/","º","ª"]
  ```
  
  If ```size``` is not a number, set ```size``` to 10.
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random(nil)
  "V@/)B*$fXG"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random("")
  "NXd6oBJJK$"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random(" ")
  "WñQcVCX1m("
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random("10")
  "Y,nEWnty/t"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random(20)
  "28ñHH5I2:$jcPCñ6kNk8"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random("30")
  "7@sX$M%7gyy,58$_p@48_rRN%VjtVO"
  ```
  """
  def generate_random(size) do
    size = NumberUtil.to_integer(size)
    size = cond do
      (size > 0) -> size
      true -> 10
    end
    generate_random_seq(size,0,@alpha_nums_random,@alpha_nums_random |> length(),[])
  end
  
  
  
  @doc """
  Generates a random string with length ```size``` containing
  only numeric 0-9 chars.
  
  If ```size``` is not a number, set ```size``` to 10.
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random_only_num(nil)
  "8842631571"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random_only_num("")
  "3983415257"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random_only_num(" ")
  "5367142216"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random_only_num(10)
  "1519486235"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random_only_num("20")
  "45396319754971833184"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random_only_num(30)
  "845951826982685147272442547731"
  ```
  """
  def generate_random_only_num(size) do
    size = NumberUtil.to_integer(size)
    size = cond do
      (size > 0) -> size
      true -> 10
    end
    generate_random_seq(size,0,only_nums(),only_nums() |> length(),[])
  end
  
  
  
  @doc """
  Generates a random string with length ```size``` containing
  only allowed chars to be used in file names.
  
  If ```size``` is not a number, set ```size``` to 10.
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random_filename(nil)
  "2mi1k281XY"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random_filename("")
  "1xdsohbWBs"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random_filename(" ")
  "3orpWPvnfg"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random_filename(10)
  "T29p17Gbqi"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random_filename("20")
  "Ry7JFypiFVl2z8jDhsg1"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.generate_random_filename(30)
  "OxC5DTSmih3BG5uj7KmK1XgWDvMBe3"
  ```
  """
  def generate_random_filename(size) do
    size = NumberUtil.to_integer(size)
    size = cond do
      (size > 0) -> size
      true -> 10
    end
    generate_random_seq(size,0,filename_chars(),filename_chars() |> length(),[])
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
    input
      |> StringUtil.raw_binary_to_string()
      |> translate_from_array_chars(@strange_chars,@translated_chars)
  end
  
  
  
  @doc """
  Convert received value to a string, make some validations of forbidden content.
  Verify some HTML injection words contained in a restriction list above.
  
  - Restriction list:
  ```elixir
    [
      "< script","<script","script>","script >",
      "</script","< /script","</ script", "< / script",
      "<body","< body",
      "< ?","<?","? >","?>",
      "../","%",
      "onerror=","onerror =",
      "onclick=","onclick =",
      "onload=","onload =",
      "alert(","alert (",
      "prompt(","prompt (",
      "eval(","eval (",
      "settimeout(","settimeout (",
      "setinterval(","setinterval (",
      "innerhtml=","innerhtml ="
    ]
    # % except when is followed by a whitespace, for example '10% '
  ```  
    
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
    input = StringUtil.replace(input,"quirbula",",",true) 
              |> StringUtil.replace("xcrept ","select ",true)
              |> StringUtil.replace("xoo ","and ",true)
              |> StringUtil.replace("yoo ","or ",true)
              |> StringUtil.replace("x43re ","where ",true)
              |> StringUtil.replace("despint","distinct",true)
              |> StringUtil.replace("xstrike ","like ",true)
              |> StringUtil.replace("quaspa","'",true)
              |> StringUtil.replace("  "," ",true)
    forbidden = input
                  |> String.downcase()
                  |> StringUtil.contains_one_element_of_array(@forbidden,true)
    cond do
      (forbidden) 
        -> nil
      true 
        -> input
    end
  end
  
  
  
  @doc """
  Convert received value to a downcase string, make some validations of 
  forbidden content for a SQL command. Verify some SQL injection words contained
  in a restriction list above.
  
  - Restriction list:
  ```elixir
    [
      "--","insert ","select ","delete ","drop ","truncate ","alter ",
      "update ","cascade ","order by ","group by ","union ",
      "having ","join ","limit ",
      "min(","min (",
      "max(","max (",
      "avg(","avg (",
      "sum(","sum (",
      "coalesce(","coalesce (",
      "distinct(","distinct (",
      "concat(","concat (",
      "group_concat(","group_concat (",
      "grant ","revoke ","commit ","rollback ",
      "../","%"
    ]
  ```
  
  If forbidden word in content are finded, return nil. Otherwise return received value.
  
  Don't use it as unique validation way for input data. First apply other validation
  methods on this module, and after that use this method for extra security.
  
  Warning: Can be throw false positives, as example if you have a innocent
  text as example: " ... there are you coices: -- do it now, or -- do it tomorrow ...", 
  or " ... take an action, select what you want do about it ... ". Be careful whit 
  this method usage to don't cause unnecessary headaches.
  
  ## Examples
  
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_sql("echo -- echo")
  nil
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_sql("echo - - echo")
  echo - - echo
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_sql("echo insert echo")
  nil
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_sql("echo inserted echo")
  echo inserted echo
  ```
  """
  @doc since: "0.4.15"
  def sanitize_sql(input) do
    forbidden = input 
                  |> String.downcase() 
                  |> StringUtil.replace("  "," ",true)
                  |> StringUtil.contains_one_element_of_array(@forbidden_sql,true)
    cond do
      (forbidden) 
        -> nil
      true 
        -> input
    end
  end
  
  
  
  @doc """
  Convert received value to a string, make some validations of forbidden content and allowed chars.
  If forbidden content or not allowed chars are finded, return empty string for 
  not numeric input values and "0" for numeric values.
  
  If ```sanitize_input``` received as true, then call additionally methods 
  to sanitize the value as comming from a html input field 
  (type: text,number and all others except textarea).
  
  ```valid_chars``` should be a string with the valid chars aceppted, separated
  by comma (ex.: "a,b,c,d,4") or a string that matches with a predefined values name.
  If ```valid_chars``` is nil/empty default value "A-z0-9" is used if
  ```is_numeric``` = false otherwise if is a number the "0-9" value used by default.
  
  Named ```valid_chars``` predefined values and respective chars:
  
  - "A-z0-9"
  ```elixir  
  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
   "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "(",")","*","-","+","%","@","_",".",",","$",":"," ","/","º","ª","?","!"]
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
   "(",")","*","-","+","%","@","_",".",",","$",":"," ","/","º","ª","?","!"]
  ```
     
  - "a-z"
  ```elixir 
  ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
   "(",")","*","-","+","%","@","_",".",",","$",":"," ","/","º","ª","?","!"]
  ```
     
  - "A-Z"
  ```elixir 
  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
   "(",")","*","-","+","%","@","_",".",",","$",":"," ","/","º","ª","?","!"]
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
  
  - "url|"
  ```elixir 
  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
   "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "(",")","*","-","+","%","@","_",".",",","$",":"," ",";","/","\\","?","=","&","[","]","{","}",
   "|","ª","º","°","!"]
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
  iex > Krug.SanitizerUtil.sanitize_all("09 8778 987",false,true,250,"0-9")
  ""
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_all("098778987",false,true,250,"0-9")
  "098778987"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_all("09 8778 987",true,true,250,"0-9")
  "0"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_all("098778987",true,true,250,"0-9")
  "098778987"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_all("09 8778 987 ABCDEF ",false,true,250,"A-z")
  ""
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_all("09 8778 987 ABCDEF ",false,true,250,"0-9")
  ""
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_all("09 8778 987 ABCDEF ",false,true,250,"A-z0-9")
  "09 8778 987 ABCDEF"
  ```
  """
  def sanitize_all(input,is_numeric,sanitize_input,max_size,valid_chars) do
    forbidden = "#{input}"
                  |> String.downcase()
                  |> StringUtil.contains_one_element_of_array(@forbidden,true)
    input = StringUtil.replace(input,"  "," ")
    cond do
      (is_numeric and forbidden) 
        -> "0"
      (forbidden) 
        -> ""
      (sanitize_input) 
        -> sanitize_input(input,is_numeric,max_size,valid_chars)
      true 
        -> StringUtil.trim(input)
    end
  end
  
  
  
  @doc """
  Sanitizes a file name to escape not allowed chars
  and force the use of file name with length <= max_size. 
  
  If any not allowed char is found, or the file name length > max_size,
  the value received is ignored and a new random name is generated 
  with the valid chars with size = max_size and return.
  
  If max_size is nil or max_size <= 0, max_size for generate a ramdom string
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
  iex > Krug.SanitizerUtil.sanitize_filename(nil,10)
  "rOufHwKL7a" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_filename("",10)
  "WQskDae0ZP" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_filename(" ",10)
  "htlp9cKxHC" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_filename(" ",10)
  "rOufHwKL7a" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_filename(" afdd#%%{}8989nfdfdd@",10)
  "ts44e22BuP" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_filename("afdd#%%{}8989nfdfdd@",100)
  "Jnn7nZICOwuuOXou4q7EBqNVtPHcYgvjh7dORJczzIlPMI7Yr5N96miqHv8gV88KTc2QOaW1yG9FJRsqeRMCKtVTbjepPKQE3whd" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_filename("Aabcde_fg.6712.89_as",10)
  "ts44e22BuP" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_filename("Aabcde_fg.6712.89_as",19)
  "ts44e22BuP" - random
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_filename("Aabcde_fg.6712.89_as",20)
  "Aabcde_fg.6712.89_as"
  ```
  ```elixir 
  iex > Krug.SanitizerUtil.sanitize_filename("Aabcde_fg.6712.89_as",50)
  "Aabcde_fg.6712.89_as"
  ```
  """
  def sanitize_filename(name,max_size) do
    cond do
      (nil == max_size or !(max_size > 0)) 
        -> sanitize_filename2(name,10)
      true -> sanitize_filename2(name,max_size)
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
    @nums
  end
  
  
  
  @doc """
  Return the valid numbers chars array.

  ## Example

  ```elixir 
  iex > Krug.SanitizerUtil.only_nums()
  ["0","1","2","3","4","5","6","7","8","9"]
  ```
  """
  def only_nums() do
    ["0","1","2","3","4","5","6","7","8","9"]
  end
  
  
  
  @doc """
  Return the valid money format chars array.

  ## Example

  ```elixir 
  iex > Krug.SanitizerUtil.money_chars()
  [",","0","1","2","3","4","5","6","7","8","9"]
  ```
  """
  def money_chars() do
    [",","0","1","2","3","4","5","6","7","8","9"]
  end
  
  
  
  @doc """
  Return the valid email chars array.

  ## Example

  ```elixir 
  iex > Krug.SanitizerUtil.email_chars()
  ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
   "0","1","2","3","4","5","6","7","8","9",
   "-","+","@","_","."]
  ```
  """
  def email_chars() do
  	["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
     "0","1","2","3","4","5","6","7","8","9",
     "-","+","@","_","."]
  end
  
  
  
  defp sanitize_input(input,is_numeric,max_size,valid_chars) do
    original_input = StringUtil.trim(input)
    translated_array = original_input |> translate() |> String.graphemes()
    size = length(translated_array)
    cond do
      (is_numeric and original_input == "") -> "0"
      (original_input == "") -> ""
      (is_numeric and max_size > 0 and (size > max_size or size == 0)) -> "0"
      (max_size > 0 and (size > max_size or size == 0)) -> ""
      true -> sanitize_by_valid_chars(original_input,translated_array,valid_chars,is_numeric)
    end
  end
  
  
  
  defp sanitize_by_valid_chars(input,translated_array,valid_chars,is_numeric) do
    enabled_chars = get_valid_chars_for_sanitize_input(valid_chars,is_numeric)
    cond do
      (is_numeric and NumberUtil.is_nan(input)) -> "0"
      (all_chars_validated_for_position(enabled_chars,translated_array)) -> input
      is_numeric -> "0"
      true -> ""
    end
  end
  
  
  
  defp all_chars_validated_for_position(enabled_chars,translated_array) do
    cond do
      (Enum.empty?(translated_array)) -> true
      (enabled_chars |> Enum.member?(translated_array |> hd()))
        -> enabled_chars |> all_chars_validated_for_position(translated_array |> tl())
      true -> false
    end
  end
  
  
  
  defp get_valid_chars_for_sanitize_input(valid_chars,is_numeric) do
    cond do
      (nil == valid_chars and is_numeric) -> @nums
      (nil == valid_chars or valid_chars == "A-z0-9") -> @alpha_nums
      (valid_chars == "A-z0-9Name") -> alpha_nums_name()
      (valid_chars == "A-z0-9|") -> alpha_nums_pipe()
      (valid_chars == "0-9") -> @nums
      (valid_chars == "A-z") -> alphas()
      (valid_chars == "a-z") -> alpha_lowers()
      (valid_chars == "A-Z") -> alpha_uppers()
      (valid_chars == "DATE_SLASH") -> date_slash()
      (valid_chars == "DATE_SQL") -> date_sql()
      (valid_chars == "email") -> email_chars()
      (valid_chars == "password") -> password_chars()
      (valid_chars == "url") -> url_chars()
      (valid_chars == "url|") -> url_chars_pipe()
      (valid_chars == "hex") -> hex_chars()
      (valid_chars == "filename") -> filename_chars()
      (StringUtil.trim(valid_chars) == "") -> @alpha_nums
      true -> valid_chars 
      			|> StringUtil.split(",",true) 
      			|> add_to_array_if_not_empty([])
    end
  end
  
  
  
  defp add_to_array_if_not_empty(arr,cleaned_array) do
    cond do
      (Enum.empty?(arr)) -> cleaned_array
      true -> add_to_array_if_not_empty(arr |> tl(),
                                        arr |> hd() |> add_to_array_if_not_empty2(cleaned_array))
    end
  end
  
  
  
  defp add_to_array_if_not_empty2(value,cleaned_array) do
    cond do
      (nil == value or StringUtil.trim(value) == "") -> cleaned_array
      true -> [value | cleaned_array]
    end
  end
  
  
  
  defp translate_from_array_chars(input,arr1,arr2) do
    cond do
      (Enum.empty?(arr1)) -> input
      true -> StringUtil.replace(input,arr1 |> hd(),arr2 |> hd(),true)
                |> translate_from_array_chars(arr1 |> tl(),arr2 |> tl())
    end
  end
  
  
  
  defp generate_random_seq(size,count,arr,arr_length,seq_arr) do
    cond do
      (count >= size) 
        -> seq_arr 
             |> IO.iodata_to_binary()
      true 
        -> generate_random_seq2(size,count,arr,arr_length,seq_arr)
    end
  end
  
  
  
  defp generate_random_seq2(size,count,arr,arr_length,seq_arr) do
    position = arr_length |> :rand.uniform()
    char = :lists.nth(position,arr) #arr |> Enum.at(position) 
    cond do
      (char == " ") 
        -> generate_random_seq2(size,count,arr,arr_length,seq_arr)
      true -> generate_random_seq(size,count + 1,arr,arr_length,[char | seq_arr])
    end
  end
  
  
  
  defp alphas() do
    ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
     "(",")","*","-","+","%","@","_",".",",","$",":"," ","/","º","ª","?","!"]
  end
  
  
  
  defp alpha_lowers() do
  	["a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
     "(",")","*","-","+","%","@","_",".",",","$",":"," ","/","º","ª","?","!"]
  end
  
  
  
  defp alpha_uppers() do
    ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "(",")","*","-","+","%","@","_",".",",","$",":"," ","/","º","ª","?","!"]
  end
  
  
  
  
  
  
  
  defp alpha_nums_name() do
  	["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
     "0","1","2","3","4","5","6","7","8","9",
     "-",","," "]
  end
  
  
  
  defp url_chars() do
  	["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
     "0","1","2","3","4","5","6","7","8","9",
     "(",")","*","-","+","%","@","_",".",",","$",":"," ",";","/","\\","?","=","&","[","]","{","}"]
  end
  
  
  
  defp url_chars_pipe() do
    ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
     "0","1","2","3","4","5","6","7","8","9",
     "(",")","*","-","+","%","@","_",".",",","$",":"," ",";","/","\\","?","=","&","[","]","{","}",
     "|","ª","º","°","!"]
  end
  
  
  
  defp password_chars() do
    ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
     "0","1","2","3","4","5","6","7","8","9",
     "*","+","%","@","_",".",",","$",":","-"]
  end
  
  
  
  defp alpha_nums_pipe() do
    ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","ñ","o","p","q","r","s","t","u","v","w","x","y","z",
     "0","1","2","3","4","5","6","7","8","9",
     "(",")","*","-","+","%","@","_",".",",","$",":"," ","/","º","ª","?","!","|"]
  end
  
  
  
  defp hex_chars() do
    ["A","B","C","D","E","F","a","b","c","d","e","f","0","1","2","3","4","5","6","7","8","9"]
  end
  
  
  
  defp filename_chars() do
    ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
     "0","1","2","3","4","5","6","7","8","9",
     "_","."]
  end
  
  
  
  defp date_slash() do
    [":","/"," ","0","1","2","3","4","5","6","7","8","9"]
  end
  
  
  
  defp date_sql() do
    [":","-"," ","0","1","2","3","4","5","6","7","8","9"]
  end
  
  
  
  defp sanitize_filename2(name,max_size) do
    sanitize_input(name,false,max_size,"filename")
      |> sanitize_filename3(max_size)
  end
  
  
  
  defp sanitize_filename3(name,max_size) do
    cond do
      (String.length(name) == 0) 
        -> generate_random_filename(max_size)
      true -> name
    end
  end
  
  
  
end