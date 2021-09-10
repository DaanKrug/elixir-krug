defmodule Krug.SanitizerUtilTest do
  use ExUnit.Case
  
  doctest Krug.SanitizerUtil
  
  alias Krug.SanitizerUtil
  
  test "[validate_email(email)]" do
    assert SanitizerUtil.validate_email(nil) == false
    assert SanitizerUtil.validate_email("") == false
    assert SanitizerUtil.validate_email([]) == false
    assert SanitizerUtil.validate_email([""]) == false
    assert SanitizerUtil.validate_email("echo@ping%com") == false
    assert SanitizerUtil.validate_email("echo@ping$com") == false
    assert SanitizerUtil.validate_email("echo@ping.com") == true
    assert SanitizerUtil.validate_email("echo@ping_com") == true
  end
  
  test "[validate_url(url)]" do
    assert SanitizerUtil.validate_url(nil) == false
    assert SanitizerUtil.validate_url("") == false
    assert SanitizerUtil.validate_url(" ") == false
    assert SanitizerUtil.validate_url([]) == false
    assert SanitizerUtil.validate_url([""]) == false
    assert SanitizerUtil.validate_url("www.google.com") == false
    assert SanitizerUtil.validate_url("http://www.google.com") == true
    assert SanitizerUtil.validate_url("https://www.google.com") == true
    assert SanitizerUtil.validate_url("https://www.echo|") == false
  end
  
  test "[has_empty(array_values)]" do
    assert SanitizerUtil.has_empty(nil) == false
    assert SanitizerUtil.has_empty([]) == false
    assert SanitizerUtil.has_empty([nil,1,2]) == true
    assert SanitizerUtil.has_empty([3,4,""]) == true
    assert SanitizerUtil.has_empty([8,7,9," "]) == true
    assert SanitizerUtil.has_empty([[],%{},9,34,"$A"]) == false
  end
  
  test "[array_has_one_less_than(array_values,value)]" do
    assert SanitizerUtil.array_has_one_less_than(nil,1) == true
    assert SanitizerUtil.array_has_one_less_than([""],1) == false
    assert SanitizerUtil.array_has_one_less_than([nil],1) == false
    assert SanitizerUtil.array_has_one_less_than([1],nil) == false
    assert SanitizerUtil.array_has_one_less_than([1],"") == false
    assert SanitizerUtil.array_has_one_less_than([1],"-1-1") == false
    assert SanitizerUtil.array_has_one_less_than([1],"10") == true
    assert SanitizerUtil.array_has_one_less_than([1,0],1) == true
    assert SanitizerUtil.array_has_one_less_than([1,0,-1],"-0.5") == true
    assert SanitizerUtil.array_has_one_less_than([1,0,-1],"-0,5.5") == false
    assert SanitizerUtil.array_has_one_less_than([1,0,-1],"-0,0.5") == true
    assert SanitizerUtil.array_has_one_less_than([1,0,-1,[],nil,%{}],"-0,0.5") == true
    assert SanitizerUtil.array_has_one_less_than([1,0,2,[],nil,%{}],"-0,0.5") == false
  end
  
  test "[generate_random(size)]" do
    rand1 = SanitizerUtil.generate_random(nil)
    rand2 = SanitizerUtil.generate_random("")
    rand3 = SanitizerUtil.generate_random(" ")
    rand4 = SanitizerUtil.generate_random(10)
    rand5 = SanitizerUtil.generate_random(20)
    rand6 = SanitizerUtil.generate_random(30)
    rand7 = SanitizerUtil.generate_random("10")
    rand8 = SanitizerUtil.generate_random("20")
    rand9 = SanitizerUtil.generate_random("30")
    assert rand1 |> String.length() == 10
    assert rand2 |> String.length() == 10
    assert rand3 |> String.length() == 10
    assert rand4 |> String.length() == 10
    assert rand5 |> String.length() == 20
    assert rand6 |> String.length() == 30
    assert rand7 |> String.length() == 10
    assert rand8 |> String.length() == 20
    assert rand9 |> String.length() == 30
    assert rand1 |> SanitizerUtil.sanitize_all(false,true,10,"A-z0-9") == rand1
    assert rand2 |> SanitizerUtil.sanitize_all(false,true,10,"A-z0-9") == rand2
    assert rand3 |> SanitizerUtil.sanitize_all(false,true,10,"A-z0-9") == rand3
    assert rand4 |> SanitizerUtil.sanitize_all(false,true,10,"A-z0-9") == rand4
    assert rand5 |> SanitizerUtil.sanitize_all(false,true,20,"A-z0-9") == rand5
    assert rand6 |> SanitizerUtil.sanitize_all(false,true,30,"A-z0-9") == rand6
    assert rand7 |> SanitizerUtil.sanitize_all(false,true,10,"A-z0-9") == rand7
    assert rand8 |> SanitizerUtil.sanitize_all(false,true,20,"A-z0-9") == rand8
    assert rand9 |> SanitizerUtil.sanitize_all(false,true,30,"A-z0-9") == rand9
  end
  
  test "[generate_random_only_num(size)]" do
    rand1 = SanitizerUtil.generate_random_only_num(nil)
    rand2 = SanitizerUtil.generate_random_only_num("")
    rand3 = SanitizerUtil.generate_random_only_num(" ")
    rand4 = SanitizerUtil.generate_random_only_num(10)
    rand5 = SanitizerUtil.generate_random_only_num(20)
    rand6 = SanitizerUtil.generate_random_only_num(30)
    rand7 = SanitizerUtil.generate_random_only_num("10")
    rand8 = SanitizerUtil.generate_random_only_num("20")
    rand9 = SanitizerUtil.generate_random_only_num("30")
    assert rand1 |> String.length() == 10
    assert rand2 |> String.length() == 10
    assert rand3 |> String.length() == 10
    assert rand4 |> String.length() == 10
    assert rand5 |> String.length() == 20
    assert rand6 |> String.length() == 30
    assert rand7 |> String.length() == 10
    assert rand8 |> String.length() == 20
    assert rand9 |> String.length() == 30
    assert rand1 |> SanitizerUtil.sanitize_all(false,true,10,"0-9") == rand1
    assert rand2 |> SanitizerUtil.sanitize_all(false,true,10,"0-9") == rand2
    assert rand3 |> SanitizerUtil.sanitize_all(false,true,10,"0-9") == rand3
    assert rand4 |> SanitizerUtil.sanitize_all(false,true,10,"0-9") == rand4
    assert rand5 |> SanitizerUtil.sanitize_all(false,true,20,"0-9") == rand5
    assert rand6 |> SanitizerUtil.sanitize_all(false,true,30,"0-9") == rand6
    assert rand7 |> SanitizerUtil.sanitize_all(false,true,10,"0-9") == rand7
    assert rand8 |> SanitizerUtil.sanitize_all(false,true,20,"0-9") == rand8
    assert rand9 |> SanitizerUtil.sanitize_all(false,true,30,"0-9") == rand9
  end
  
  test "[generate_random_filename(size)]" do
    rand1 = SanitizerUtil.generate_random_filename(nil)
    rand2 = SanitizerUtil.generate_random_filename("")
    rand3 = SanitizerUtil.generate_random_filename(" ")
    rand4 = SanitizerUtil.generate_random_filename(10)
    rand5 = SanitizerUtil.generate_random_filename(20)
    rand6 = SanitizerUtil.generate_random_filename(30)
    rand7 = SanitizerUtil.generate_random_filename("10")
    rand8 = SanitizerUtil.generate_random_filename("20")
    rand9 = SanitizerUtil.generate_random_filename("30")
    assert rand1 |> String.length() == 10
    assert rand2 |> String.length() == 10
    assert rand3 |> String.length() == 10
    assert rand4 |> String.length() == 10
    assert rand5 |> String.length() == 20
    assert rand6 |> String.length() == 30
    assert rand7 |> String.length() == 10
    assert rand8 |> String.length() == 20
    assert rand9 |> String.length() == 30
    assert rand1 |> SanitizerUtil.sanitize_all(false,true,10,"filename") == rand1
    assert rand2 |> SanitizerUtil.sanitize_all(false,true,10,"filename") == rand2
    assert rand3 |> SanitizerUtil.sanitize_all(false,true,10,"filename") == rand3
    assert rand4 |> SanitizerUtil.sanitize_all(false,true,10,"filename") == rand4
    assert rand5 |> SanitizerUtil.sanitize_all(false,true,20,"filename") == rand5
    assert rand6 |> SanitizerUtil.sanitize_all(false,true,30,"filename") == rand6
    assert rand7 |> SanitizerUtil.sanitize_all(false,true,10,"filename") == rand7
    assert rand8 |> SanitizerUtil.sanitize_all(false,true,20,"filename") == rand8
    assert rand9 |> SanitizerUtil.sanitize_all(false,true,30,"filename") == rand9
  end
  
  test "[sanitize(input)]" do
    assert SanitizerUtil.sanitize("echo <script echo") == nil
    assert SanitizerUtil.sanitize("echo < script echo") == nil
    assert SanitizerUtil.sanitize("echo script> echo") == nil
    assert SanitizerUtil.sanitize("echo script > echo") == nil
    assert SanitizerUtil.sanitize("echoscript>echo") == nil
    assert SanitizerUtil.sanitize("echoscriptecho") == "echoscriptecho"
    assert SanitizerUtil.sanitize("echo <      ? echo") == nil
    assert SanitizerUtil.sanitize("echo <? echo") == nil
    assert SanitizerUtil.sanitize("echo ?      > echo") == nil
    assert SanitizerUtil.sanitize("echo ?> echo") == nil
    assert SanitizerUtil.sanitize("echo <      % echo") == nil
    assert SanitizerUtil.sanitize("echo <% echo") == nil
    assert SanitizerUtil.sanitize("echo %      > echo") == nil
    assert SanitizerUtil.sanitize("echo %> echo") == nil
  end
  
  test "[sanitize_all(input,is_numeric,sanitize_input,max_size,valid_chars)]" do
    assert SanitizerUtil.sanitize_all("09 8778 987",false,true,250,"0-9") == ""
    assert SanitizerUtil.sanitize_all("098778987",false,true,250,"0-9") == "098778987"
    assert SanitizerUtil.sanitize_all("09 8778 987",true,true,250,"0-9") == "0"
    assert SanitizerUtil.sanitize_all("098778987",true,true,250,"0-9") == "098778987"
    assert SanitizerUtil.sanitize_all("09 8778 987 ABCDEF ",false,true,250,"A-z") == ""
    assert SanitizerUtil.sanitize_all("09 8778 987 ABCDEF ",false,true,250,"0-9") == ""
    assert SanitizerUtil.sanitize_all("09 8778 987 ABCDEF ",false,true,250,"A-z0-9") == "09 8778 987 ABCDEF"
  end
  
  test "[sanitize_sql(input)]" do
    assert SanitizerUtil.sanitize_sql("echo -- echo") == nil
    assert SanitizerUtil.sanitize_sql("echo insert echo") == nil
    assert SanitizerUtil.sanitize_sql("echo select echo") == nil
    assert SanitizerUtil.sanitize_sql("echo delete echo") == nil
    assert SanitizerUtil.sanitize_sql("echo drop echo") == nil
    assert SanitizerUtil.sanitize_sql("echo truncate echo") == nil
    assert SanitizerUtil.sanitize_sql("echo alter echo") == nil
    assert SanitizerUtil.sanitize_sql("echo update echo") == nil
    assert SanitizerUtil.sanitize_sql("echo cascade echo") == nil
    assert SanitizerUtil.sanitize_sql("echo order by echo") == nil
    assert SanitizerUtil.sanitize_sql("echo group by echo") == nil
    assert SanitizerUtil.sanitize_sql("echo union echo") == nil
    assert SanitizerUtil.sanitize_sql("echo having echo") == nil
    assert SanitizerUtil.sanitize_sql("echo join echo") == nil
    assert SanitizerUtil.sanitize_sql("echo limit echo") == nil
    assert SanitizerUtil.sanitize_sql("echo min( echo") == nil
    assert SanitizerUtil.sanitize_sql("echo max( echo") == nil
    assert SanitizerUtil.sanitize_sql("echo avg( echo") == nil
    assert SanitizerUtil.sanitize_sql("echo sum( echo") == nil
    assert SanitizerUtil.sanitize_sql("echo distinct( echo") == nil
    assert SanitizerUtil.sanitize_sql("echo coalesce( echo") == nil
    assert SanitizerUtil.sanitize_sql("echo concat( echo") == nil
    assert SanitizerUtil.sanitize_sql("echo group_concat( echo") == nil
    assert SanitizerUtil.sanitize_sql("echo grant echo") == nil
    assert SanitizerUtil.sanitize_sql("echo revoke echo") == nil
    assert SanitizerUtil.sanitize_sql("echo commit echo") == nil
    assert SanitizerUtil.sanitize_sql("echo rollback echo") == nil
  end
  
  test "[sanitize_filename(name,max_size)]" do
    assert SanitizerUtil.sanitize_filename(nil,10) != ""
    assert SanitizerUtil.sanitize_filename("",10) != ""
    assert SanitizerUtil.sanitize_filename(" ",10) != ""
    assert SanitizerUtil.sanitize_filename(" afdd#%%{}8989nfdfdd@",10) != " afdd#%%{}8989nfdfdd@"
    assert SanitizerUtil.sanitize_filename("afdd#%%{}8989nfdfdd@",100) != " afdd#%%{}8989nfdfdd@"
    assert SanitizerUtil.sanitize_filename("Aabcde_fg.6712.89_as",10) != "Aabcde_fg."
    assert SanitizerUtil.sanitize_filename("Aabcde_fg.6712.89_as",15) != "Aabcde_fg.6712."
    assert SanitizerUtil.sanitize_filename("Aabcde_fg.6712.89_as",19) != "Aabcde_fg.6712.89_a"
    assert SanitizerUtil.sanitize_filename("Aabcde_fg.6712.89_as",20) == "Aabcde_fg.6712.89_as"
    assert SanitizerUtil.sanitize_filename("Aabcde_fg.6712.89_as",50) == "Aabcde_fg.6712.89_as"
    assert SanitizerUtil.sanitize_filename("Aabcde_fg.6712.89_as",100) == "Aabcde_fg.6712.89_as"
  end
  
  test "[nums()]" do
    assert SanitizerUtil.nums() == ["-",".","0","1","2","3","4","5","6","7","8","9"]
  end
  
  test "[only_nums()]" do
    assert SanitizerUtil.only_nums() == ["0","1","2","3","4","5","6","7","8","9"]
  end
  
  test "[money_chars()]" do
    assert SanitizerUtil.money_chars() == [",","0","1","2","3","4","5","6","7","8","9"]
  end
  
end