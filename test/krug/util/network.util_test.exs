defmodule Krug.NetworkUtilTest do
  use ExUnit.Case
  
  doctest Krug.NetworkUtil
  
  alias Krug.NetworkUtil
  
  test "[generate_ipv4_netmask_16_24_ip_list(ipv4_address,ipv4_netmask)]" do
    ipv4_address = "192.168.10.200"
    ipv4_netmask = "255.255.255.0"
    ip_list = NetworkUtil.generate_ipv4_netmask_16_24_ip_list(ipv4_address,ipv4_netmask)
    assert ip_list |> length() == 256
    
    ipv4_address = "192.168.10.200"
    ipv4_netmask = "255.255.0.0"
    ip_list = NetworkUtil.generate_ipv4_netmask_16_24_ip_list(ipv4_address,ipv4_netmask)
    assert ip_list |> length() == (256 * 256)
  end
  
end