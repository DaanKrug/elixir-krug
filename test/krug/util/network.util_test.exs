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
    assert ip_list |> length() == (256 * 21)
    
    ipv4_address = "192.168.42.200"
    ipv4_netmask = "255.255.0.0"
    ip_list = NetworkUtil.generate_ipv4_netmask_16_24_ip_list(ipv4_address,ipv4_netmask)
    assert ip_list |> length() == (256 * 21)
  end
  
  test "[get_minor_node(node_list)]" do
    node_list = [
      :"app@192.168.10.20",
      :"app@192.168.10.20",
      :"app@192.168.10.20"
    ]
    assert node_list |> NetworkUtil.get_minor_node() == :"app@192.168.10.20"
    
    node_list = [
      :"app@192.168.10.22",
      :"app@192.168.10.21",
      :"app@192.168.10.20",
      :"app@192.168.10.23"
    ]
    assert node_list |> NetworkUtil.get_minor_node() == :"app@192.168.10.20"
    
    node_list = [
      :"app@192.168.10.20",
      :"app@192.168.9.20",
      :"app@192.168.8.20",
      :"app@192.168.11.20"
    ]
    assert node_list |> NetworkUtil.get_minor_node() == :"app@192.168.8.20"
    
    node_list = [
      :"app@192.168.10.20",
      :"app@192.166.10.20",
      :"app@192.167.10.20",
      :"app@192.164.10.20",
      :"app@192.169.10.20"
    ]
    assert node_list |> NetworkUtil.get_minor_node() == :"app@192.164.10.20"
    
    node_list = [
      :"app@193.168.10.20",
      :"app@192.168.10.20",
      :"app@191.168.10.20",
      :"app@190.168.10.20",
      :"app@195.168.10.20"
    ]
    assert node_list |> NetworkUtil.get_minor_node() == :"app@190.168.10.20"
    
  end
  
  test "[get_major_node(node_list)]" do
    node_list = [
      :"app@192.168.10.20",
      :"app@192.168.10.20",
      :"app@192.168.10.20"
    ]
    assert node_list |> NetworkUtil.get_major_node() == :"app@192.168.10.20"
    
    node_list = [
      :"app@192.168.10.22",
      :"app@192.168.10.21",
      :"app@192.168.10.20",
      :"app@192.168.10.23"
    ]
    assert node_list |> NetworkUtil.get_major_node() == :"app@192.168.10.23"
    
    node_list = [
      :"app@192.168.10.20",
      :"app@192.168.9.20",
      :"app@192.168.8.20",
      :"app@192.168.11.20"
    ]
    assert node_list |> NetworkUtil.get_major_node() == :"app@192.168.11.20"
    
    node_list = [
      :"app@192.168.10.20",
      :"app@192.166.10.20",
      :"app@192.167.10.20",
      :"app@192.164.10.20",
      :"app@192.169.10.20"
    ]
    assert node_list |> NetworkUtil.get_major_node() == :"app@192.169.10.20"
    
    node_list = [
      :"app@193.168.10.20",
      :"app@192.168.10.20",
      :"app@191.168.10.20",
      :"app@190.168.10.20",
      :"app@195.168.10.20"
    ]
    assert node_list |> NetworkUtil.get_major_node() == :"app@195.168.10.20"
      
  end
  
end
