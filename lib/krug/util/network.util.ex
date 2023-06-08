defmodule Krug.NetworkUtil do

  @moduledoc """
  Utilitary module to handle network info
  """
  @moduledoc since: "1.1.17"
  
  
  
  alias Krug.StringUtil
  alias Krug.MapUtil
  
  
  
  @ip_regexp ~r/^\d+\.\d+\.\d+\.\d+$/
  
  
  
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
  Obtains the local machine ipv4 local network
  """
  def get_local_wlan_ip_v4() do
    :inet.getifaddrs()
      |> Tuple.to_list()
      |> tl()
      |> hd()
      |> filter_local_wlan_ip()
  end
  
  
  
  defp filter_local_wlan_ip(ips_list, local_ip \\ nil) do
    cond do
      (Enum.empty?(ips_list))
        -> local_ip
      true
        -> ips_list
             |> filter_local_wlan_ip2()
    end
  end


  
  defp filter_local_wlan_ip2(ips_list) do
    list = ips_list 
             |> hd()
             |> Tuple.to_list()
    cond do
      (String.starts_with?("#{list |> hd()}","wl"))
        -> filter_local_wlan_ip([], list |> extract_local_ip())
      true
        -> ips_list 
             |> tl() 
             |> filter_local_wlan_ip()
    end
  end
  

  
  defp extract_local_ip(list) do
    data = list
             |> tl() 
             |> hd()
             |> Enum.filter(
                  fn({k,v}) ->
                    (k == :addr and :inet.is_ipv4_address(v))
                  end
                )
    data 
      |> Enum.into(%{})
      |> MapUtil.get(:addr)
      |> :inet.ntoa()
  end
  
  
  
end