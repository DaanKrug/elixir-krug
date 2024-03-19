defmodule Krug.CipherUtilTest do
  use ExUnit.Case
  
  doctest Krug.CipherUtil
  
  alias Krug.CipherUtil
  
  test "[calculate_string_value(string)]" do
    assert CipherUtil.calculate_string_value(nil) == 0
    assert CipherUtil.calculate_string_value("") == 0
    assert CipherUtil.calculate_string_value(" ") == 0
    assert CipherUtil.calculate_string_value("A") == 130
    assert CipherUtil.calculate_string_value(" A ") == 130
    assert CipherUtil.calculate_string_value("AA") == 390
    assert CipherUtil.calculate_string_value("ABC") == 930
    assert CipherUtil.calculate_string_value("Aa") == 518
    assert CipherUtil.calculate_string_value("Abc") == 1314
    assert CipherUtil.calculate_string_value("ABc") == 1186
    email = "jao.silva@factory.com"
    assert CipherUtil.calculate_string_value(email) == 439402320
    email = "echo.ping@blabla.com"
    assert CipherUtil.calculate_string_value(email) == 217583302
    email = "jhon.titor@timetraveler.com"
    assert CipherUtil.calculate_string_value(email) == 28001410572
    email = "jao+silva@factory.com"
    assert CipherUtil.calculate_string_value(email) == 439402272
    email = "jao-silva@factory.com"
    assert CipherUtil.calculate_string_value(email) == 439402304
    email = "jao_silva@factory.com"
    assert CipherUtil.calculate_string_value(email) == 439403104
    email = "jao_silva@factory.comjao-silva@factory.com"
    assert CipherUtil.calculate_string_value(email) == 921493860041312
    email = "jao_silva@factory.comjao-silva@factory.comjao-silva@factory.com"
    assert CipherUtil.calculate_string_value(email) == 1932512691572119224928
    email = "jao_silva@factory.comjao-silva@factory.comjao-silva@factory.comjao-silva@factory.com"
    assert CipherUtil.calculate_string_value(email) == 4052772856155852975557886560
    long_email = "#{email}#{email}#{email}"
    long_email_result = 1516322346240516868051923680141681330343837348583517591307263277829846985654880
    assert CipherUtil.calculate_string_value(long_email) == long_email_result
    long_email2 = "#{email}#{email}#{email}#{email}"
    long_email2_result = 29329939763660710047221249706613443500366242784436853354546683350912627791837594743591176147550606508640
    assert CipherUtil.calculate_string_value(long_email2) == long_email2_result
  end
  
  
end