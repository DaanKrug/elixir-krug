defmodule Krug.GenericSMTPMailer do

  @moduledoc false

  require Logger
  alias Bamboo.Formatter
  alias Krug.MapUtil


  def deliver_now(email,dynamicconfig_override \\ %{}) do
    config = build_config(dynamicconfig_override)
    deliver_now(config.adapter,email,config)
  end
  
  defp deliver_now(adapter,email,config) do
    email = email |> validate_and_normalize(adapter)
    cond do
      (nil == email or nil == MapUtil.get(email,:to)) -> debugg_unsent(email)
      true -> deliver_and_debugg_sent(email,config,adapter)
    end
    email
  end
  
  defp deliver_and_debugg_sent(email,config,adapter) do
    Logger.debug(fn ->
      """
      Sending email with #{inspect(adapter)}:
      #{inspect(email, limit: 150)}
      """
    end)
    adapter.deliver(email,config)
  end

  defp debugg_unsent(email) do
    Logger.debug(fn ->
      """
      Email was not sent because recipients are empty.
      Full email - #{inspect(email, limit: 150)}
      """
    end)
  end

  defp validate_and_normalize(email,adapter) do
    email |> validate(adapter) |> normalize_addresses()
  end

  defp validate(email,adapter) do
    email
      |> validate_from_address()
      |> validate_recipients()
      |> validate_attachment_support(adapter)
  end

  defp validate_attachment_support(%{attachments: []} = email, _adapter) do
    email
  end

  defp validate_attachment_support(email,adapter) do
    cond do
      (!(function_exported?(adapter, :supports_attachments?, 0))) 
        -> raise("the #{adapter} does not support attachments yet.")
      (!(adapter.supports_attachments?()))
        -> raise("the #{adapter} does not support attachments yet.")
      true -> email
    end
  end

  defp validate_from_address(%{from: nil}) do
    raise(Bamboo.EmptyFromAddressError,nil)
  end

  defp validate_from_address(%{from: {_, nil}}) do
    raise(Bamboo.EmptyFromAddressError,nil)
  end

  defp validate_from_address(email) do
    email
  end

  defp validate_recipients(%Bamboo.Email{} = email) do
    cond do
      (Enum.all?(Enum.map([:to, :cc, :bcc], &Map.get(email,&1)),&isNilRecipient?/1))
        -> raise(Bamboo.NilRecipientsError,email)
      true -> email
    end
  end

  defp isNilRecipient?(nil) do
    true
  end
  
  defp isNilRecipient?({_, nil}) do
    true
  end
  
  defp isNilRecipient?([]) do
    false
  end
  
  defp isNilRecipient?([_ | _] = recipients) do
    Enum.all?(recipients, &isNilRecipient?/1)
  end
  
  defp isNilRecipient?(_) do
    false
  end

  def normalize_addresses(email) do
    %{
      email
      | from: format(email.from, :from),
        to: format(List.wrap(email.to), :to),
        cc: format(List.wrap(email.cc), :cc),
        bcc: format(List.wrap(email.bcc), :bcc)
    }
  end

  defp format(record,type) do
    Formatter.format_email_address(record, %{type: type})
  end
  
  defp build_config(dynamicconfig_override) do
    get_base_build_smtp_config() 
      |> Map.new()
      |> Map.merge(dynamicconfig_override)
      |> handle_adapter_config()
  end

  defp handle_adapter_config(base_config = %{adapter: adapter}) do
    adapter.handle_config(base_config)
      |> Map.put_new(:deliver_later_strategy,Bamboo.TaskSupervisorStrategy)
  end
  
  defp get_base_build_smtp_config() do
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
  end

end