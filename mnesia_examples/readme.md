

# append the task starter on Application, once in machine A and once in machine B

defmodule ExApp.Application do
  
  @moduledoc false

  use Application

  def start(_type, _args) do
  
    Supervisor.start_link(children(), opts())
  
  end
  
  defp children() do
  
  	[
      ExApp.MnesiaTestTaskStarter
  	]
  
  end
 
end