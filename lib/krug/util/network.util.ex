defmodule Krug.NetworkUtil do

  @moduledoc """
  Utilitary module to handle network info
  """
  @moduledoc since: "1.1.17"
  
  
  
  alias Krug.StringUtil
  alias Krug.MapUtil
  alias Krug.NumberUtil
  
  
  
  @ip_regexp ~r/^\d+\.\d+\.\d+\.\d+$/
  @exponent_a 256 * 256 * 256
  @exponent_b 256 * 256
  @exponent_c 256
  
  
  @doc """
  Start the local node from a cluster of nodes
  """
  def start_local_node_to_cluster_ip_v4(cluster_name,cluster_cookie) do
    local_node = "#{cluster_name}@#{get_local_wlan_ip_v4()}" 
                   |> String.to_atom()
    [
      local_node,
      :longnames
    ]
      |> :net_kernel.start()
    cluster_cookie
      |> String.to_atom()
      |> :erlang.set_cookie() 
    local_node
  end
  
  
  
  @doc """
  Extract a list of valid ip v4 addresses from a "ips_string", splitted by the "ips_separator".
  """
  def extract_valid_ip_v4_addresses(ips_string,ips_separator) do
    ips_string
      |> StringUtil.trim()
      |> StringUtil.split(ips_separator)
      |> Enum.filter(
           fn 
             ip -> String.match?(ip,@ip_regexp) 
           end
         )
  end
  
  
  
  @doc """
  Obtains the local machine ipv4 local network IP (i.e: 192.168.1.2 | 172.0.0.2)
  """
  def get_local_wlan_ip_v4() do
    :inet.getifaddrs()
      |> Tuple.to_list()
      |> tl()
      |> hd()
      |> filter_local_wlan_ip()
  end
  
  
  
  @doc """
  Obtains the local machine ipv4 local netmask (i.e: 255.255.0.0 | 255.255.255.0)
  """
  def get_local_wlan_ip_v4_netmask() do
    :inet.getifaddrs()
      |> Tuple.to_list()
      |> tl()
      |> hd()
      |> filter_local_wlan_ip(true)
  end
  
  
  
  @doc """
  Based in a IP address and a netmask (subnet /16 or /24),
  generates a list of IP addresses suposed by in a same network/VPC
  
  For subnets /16 will be returned only a limit range of ≃10%
  of all possible IP's. This will be IP's that are near neighboors
  of given "ipv4_address". 
  Example given "ipv4_address" was 192.168.40.120, then
  the first will be 192.168.30.0 and the last will be 192.168.50.255
  """
  def generate_ipv4_netmask_16_24_ip_list(ipv4_address,ipv4_netmask) do
    netmask_16 = ipv4_netmask
                   |> StringUtil.split(".")
                   |> Enum.at(2)
    ip_array = ipv4_address
                 |> StringUtil.split(".")
                 |> Enum.reverse()
                 |> tl()
    cond do
      (netmask_16 == "0")
        -> ip_array
             |> tl()
             |> Enum.reverse()
             |> generate_ipv4_netmask_16_ip_list(
                  ip_array
                    |> hd()
                    |> netmask_16_calculate_start_range()
                )
      true
        -> ip_array
             |> Enum.reverse()
             |> generate_ipv4_netmask_24_ip_list()
    end
  end
  
  
  
  @doc """
  Filter the nodes list (atom list on format :"my_cookie@ipv4") according IP address
  and get the minor address.
  """
  def get_minor_node(node_list) do
    node_list
      |> get_minor_node2()
  end
  
  
  
  @doc """
  Filter the nodes list (atom list on format :"my_cookie@ipv4") according IP address
  and get the major address.
  """
  def get_major_node(node_list) do
    node_list
      |> get_major_node2()
  end
  
  
  
  ###########################################
  # Private functions
  ###########################################
  defp netmask_16_calculate_start_range(ip_third_position) do
    ip_third_position = ip_third_position
                         |> NumberUtil.to_integer()
    cond do
      (ip_third_position > 10)
        -> ip_third_position - 11
      true
        -> 0
    end
  end
  
  
  
  defp filter_local_wlan_ip(ips_list,netmask \\ false,local_ip \\ nil) do
    cond do
      (Enum.empty?(ips_list))
        -> local_ip
      true
        -> ips_list
             |> filter_local_wlan_ip2(netmask)
    end
  end


  
  defp filter_local_wlan_ip2(ips_list,netmask) do
    list = ips_list 
             |> hd()
             |> Tuple.to_list()
    cond do
      (String.starts_with?("#{list |> hd()}","wl"))
        -> filter_local_wlan_ip([],netmask,list |> extract_local_ip(netmask))
      true
        -> ips_list 
             |> tl() 
             |> filter_local_wlan_ip(netmask)
    end
  end
  

  
  defp extract_local_ip(list,netmask) do
    data = list
             |> tl() 
             |> hd()
             |> Enum.filter(
                  fn({k,v}) ->
                    (!netmask and k == :addr and :inet.is_ipv4_address(v))
                    or
                    (netmask and k == :netmask and :inet.is_ipv4_address(v))
                  end
                )
    cond do
      (netmask)
        -> data 
	         |> Enum.into(%{})
	         |> MapUtil.get(:netmask)
	         |> :inet.ntoa()
      true
        -> data 
             |> Enum.into(%{})
             |> MapUtil.get(:addr)
             |> :inet.ntoa()
    end
  end
  
  
  
  defp generate_ipv4_netmask_16_ip_list(ipv4_base_array,start_position,counter \\ 0,ipv4_array_list \\ []) do
    cond do
      (counter > 20)
        -> ipv4_array_list
      true
        -> ipv4_base_array
             |> generate_ipv4_netmask_16_ip_list(
                  start_position,
                  counter + 1,
                  ipv4_base_array
                    |> generate_ipv4_netmask_16_ip_list2(start_position + counter,ipv4_array_list)
                )      
    end
  end
  
  
  
  defp generate_ipv4_netmask_16_ip_list2(ipv4_base_array,counter,ipv4_array_list) do
    [
      counter 
      | ipv4_base_array |> Enum.reverse()
    ]
      |> Enum.reverse()
      |> generate_ipv4_netmask_24_ip_list(0,ipv4_array_list)
  end
  
  
  
  defp generate_ipv4_netmask_24_ip_list(ipv4_base_array,counter \\ 0,ipv4_array_list \\ []) do
    cond do
      (counter > 255)
        -> ipv4_array_list
      true
        -> ipv4_base_array
             |> generate_ipv4_netmask_24_ip_list(
                  counter + 1,
                  add_ipv4_on_list(ipv4_base_array,ipv4_array_list,counter)
                )
    end
  end
  
  
  
  defp add_ipv4_on_list(ipv4_base_array,ipv4_array_list,counter) do
    [
      add_ipv4_block(ipv4_base_array,counter)
      | ipv4_array_list
    ]
  end
  
  
  
  defp add_ipv4_block(ipv4_base_array,counter) do
    [
      counter 
      | ipv4_base_array |> Enum.reverse()
    ] 
      |> Enum.reverse()
      |> Enum.join(".")
  end
  
  
  
  defp get_minor_node2(node_list,minor \\ nil) do
    cond do
      (Enum.empty?(node_list))
        -> minor
      (nil == minor)
        -> node_list
             |> tl()
             |> get_minor_node2(node_list |> hd())
      true
        -> node_list
             |> tl()
             |> get_minor_node2(
                  get_minor_node_by_value(minor,node_list |> hd())
                )
    end
  end
  
  
  
  defp get_major_node2(node_list,major \\ nil) do
    cond do
      (Enum.empty?(node_list))
        -> major
      (nil == major)
        -> node_list
             |> tl()
             |> get_major_node2(node_list |> hd())
      true
        -> node_list
             |> tl()
             |> get_major_node2(
                  get_major_node_by_value(major,node_list |> hd())
                )
    end
  end
  
  
  
  defp get_minor_node_by_value(current,candidate) do
    [current_value,candidate_value] = current
                                        |> extract_nodes_value(candidate)
    cond do
      (current_value <= candidate_value)
        -> current
      true
        -> candidate
    end
  end
  
  
  
  defp get_major_node_by_value(current,candidate) do
    [current_value,candidate_value] = current
                                        |> extract_nodes_value(candidate)
    cond do
      (current_value >= candidate_value)
        -> current
      true
        -> candidate
    end
  end
  
  
  
  defp extract_nodes_value(current,candidate) do
    [
      current
        |> extract_node_ip_comparison_value(),
      candidate
        |> extract_node_ip_comparison_value()
    ]
  end
  
  
  
  defp extract_node_ip_comparison_value(node) do
    [a,b,c,d] = node
                  |> Atom.to_string()
                  |> StringUtil.split("@")
                  |> tl()
                  |> hd()
                  |> StringUtil.split(".")
    a = a
          |> NumberUtil.to_integer()
    b = b
          |> NumberUtil.to_integer()
    c = c
          |> NumberUtil.to_integer()
    d = d
          |> NumberUtil.to_integer()
    (a * @exponent_a) + (b * @exponent_b) + (c * @exponent_c) + d       
  end
  
  
  
end


