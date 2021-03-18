defmodule Krug.AwsSesMailSender do

  @moduledoc """
  A module to simplify use of Bamboo SMTP mailing
  with the "AWS SES" smtp provider.
  
  Documentation at https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-an-email-using-smtp.html
  """
  @moduledoc since: "0.4.7"
  
  alias Krug.GenericMail
  alias Krug.GenericSMTPMailer



  @doc """
  Send mail over "AWS SES" smtp provider. 
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
	      server: "email-smtp.us-west-2.amazonaws.com", # https://docs.aws.amazon.com/general/latest/gr/ses.html
	      username: "YOUR_SES_USER_NAME", 
	      sender_name: "Johannes Backend",
	      sender_email: "johannesbackend@has.not.email",
	      sender_password: "YOUR_SES_USER_PASSWORD", 
	      replay_to: "", # put your reply-to address, or leave blank
		  ssl: true # required to be true
	    }
  iex > Krug.AwsSesMailSender.mail(email_configuration,"Lets Party","Party Tommorow at 18:30","any@any.com")
  false
  ```
  ```elixir
  iex > email_configuration = %{
	      server: "email-smtp.us-west-2.amazonaws.com", # https://docs.aws.amazon.com/general/latest/gr/ses.html
	      username: "YOUR_SES_USER_NAME", 
	      sender_name: "Johannes Backend",
	      sender_email: "johannesbackend@has.not.email",
	      sender_password: "YOUR_SES_USER_PASSWORD", 
	      replay_to: "",# put your reply-to address, or leave blank
		  ssl: true # required to be true
	    }
  iex > Krug.AwsSesMailSender.mail(email_configuration,"Lets Party","Party Tommorow at 18:30","any@any.com")
  true
  ```
  """
  def mail(email_configuration,title,body,tto) do
    try do
  	  try do
  	    credentials = %{server: email_configuration.server, 
  	                    username: email_configuration.username, 
  	                    password: email_configuration.sender_password, 
  	                    port: 587}
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