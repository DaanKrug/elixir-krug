defmodule Krug.GenericMail do

  @moduledoc false

  import Bamboo.Email

  def get_email(email_configuration,title,body,tto) do
    from = {email_configuration.sender_name,email_configuration.sender_email}
    new_email(to: tto,from: from,subject: title,html_body: body)
      |> put_header("Reply-To",email_configuration.replay_to)
  end
  
end