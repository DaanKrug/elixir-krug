defmodule Krug.SkallertenMailSender do
  
  @moduledoc """
  A module to simplify use of Bamboo SMTP mailing
  with the "Skallerten" smtp provider.
  
  Restriction of use: allowed only for Skallerten applications.
  """
  @moduledoc since: "0.3.0"
  
  alias Krug.StringUtil
  alias Krug.GenericMail
  alias Krug.GenericSMTPMailer



  @doc """
  Send mail over "Skallerten" smtp provider. 
  Don't uses config.exs file for configuration read. Uses following 
  conventioned configurations:
  ```
  [
    adapter: Bamboo.SMTPAdapter,
    chained_adapter: Bamboo.SMTPAdapter,
    server: "",
    port: 587,
    username: "",
    password: "",
    api_key: "my_api_key",
    tls: :always,
    allowed_tls_versions: {:system, "ALLOWED_TLS_VERSIONS"},
    ssl: false,
    retries: 0,
    no_mx_lookups: false,
    auth: :always
  ]
  ```
  Received configurations options will be merged in this above. Configurations
  specific for this smtp provider too.
  
  Return true if call to smtp provider results without errors. However the mail can be not delivered
  for any reason, by example restrictions quotas. 
  
  ```elixir
  iex > email_configuration = %{
	      sender_name: "Johannes Backend",
	      sender_email: "johannes@has.not.email",
	      sender_password: nil,
	      replay_to: "johannes_chief@johannesenterpriseserver.com"
	    }
  iex > Krug.SkallertenMailSender.mail(email_configuration,"Lets Party","Party Tommorow at 18:30","any@any.com")
  false
  ```
  ```elixir
  iex > email_configuration = %{
	      sender_name: "Johannes Backend",
	      sender_email: "johannes@has.not.email",
	      sender_password: "<johannes_password>",
	      replay_to: "johannes_chief@johannesenterpriseserver.com"
	    }
  iex > Krug.SkallertenMailSender.mail(email_configuration,"Lets Party","Party Tommorow at 18:30","any@any.com")
  true
  ```
  """
  def mail(email_configuration,title,body,tto) do
  	cond do
  	  (!addressCanBeReached(tto)) -> false
  	  true -> sendmail(email_configuration,title,body,tto)
  	end
  end
  
  
  
  defp sendmail(email_configuration,title,body,tto) do
  	try do
	  try do
	  	credentials = %{server: "mail.skallerten.com.br", 
	                    username: email_configuration.sender_email, 
	                    password: email_configuration.sender_password}
	  	GenericMail.get_email(email_configuration,title,body,tto)
	      |> GenericSMTPMailer.deliver_now(credentials)
	    true
	  rescue
	  	 _ -> false
	  end
  	catch
  	  _ -> false
  	end
  end
  
  
  
  defp addressCanBeReached(tto) do
    provider = tto |> StringUtil.split("@") |> Enum.at(1)
  	!(Enum.member?(notRecheableDomains(),provider))
  end
  
  
  
  defp notRecheableDomains() do
  	["hotmail.com","mail.com","outlook.com","outlook.com.br",
  	 "outlook.fr","outlook.de",
  	 "live.com","msn.com",
  	 "gmx.com","gmx.de","twcmail.de","web.de",
  	 "ufpr.br","furb.br","icloud.com"]
  end



end
