defmodule Krug.SocketLabSender do
  
  @moduledoc """
  A module to simplify use of Bamboo SMTP mailing
  with the "SocketLab" smtp provider.
  
  Documentation at https://www.socketlabs.com
  """
  @moduledoc since: "0.3.0"
  
  alias Krug.GenericMail
  alias Krug.GenericSMTPMailer
  alias Krug.StringUtil



  @doc """
  Send mail over "SocketLab" smtp provider. 
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
  
  SocketLab don't uses a sender_email as smtp username.
  Because of this, the sender_password key in email_configuration
  should contain username and password, joined whit 1 comma.
  
  ```elixir
  iex > email_configuration = %{
	      sender_name: "Johannes Backend",
	      sender_email: "johannes@has.not.email",
	      sender_password: nil,
	      replay_to: "johannes_chief@johannesenterpriseserver.com"
	    }
  iex > Krug.SocketLabSender.mail(email_configuration,"Lets Party","Party Tommorow at 18:30","any@any.com")
  false
  ```
  ```elixir
  iex > email_configuration = %{
	      sender_name: "Johannes Backend",
	      sender_email: "johannes@has.not.email",
	      sender_password: "<johannes_username>,<johannes_password>",
	      replay_to: "johannes_chief@johannesenterpriseserver.com"
	    }
  iex > Krug.SocketLabSender.mail(email_configuration,"Lets Party","Party Tommorow at 18:30","any@any.com")
  true
  ```
  """
  def mail(email_configuration,title,body,tto) do
    try do
  	  try do
  	    arr = email_configuration.sender_password |> StringUtil.split(",")
        credentials = %{server: "smtp.socketlabs.com", 
  	                    username: Enum.at(arr,0), 
  	                    password: Enum.at(arr,1)}
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



end