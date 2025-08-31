defmodule Krug.DistributedMnesiaMasterControlTask do

  @moduledoc false
  
  
  
  use Task
  alias Krug.DistributedMnesiaMasterControl
  
  
  
  def start_link(_opts) do
    Task.start_link(__MODULE__, :correct_master_node, [])
  end
  
  
  
  def correct_master_node() do
    # ["correct_master_node .... "] |> IO.inspect()
    cond do
      (DistributedMnesiaMasterControl.node_is_running(node()))
        -> verify_and_correct_master_node()
      true
        -> :ok # mnesia stopped
    end
  end
  

  
  defp verify_and_correct_master_node() do
    DistributedMnesiaMasterControl.verify_and_correct_master_node()
    DistributedMnesiaMasterControl.read_correct_master_node_interval()
      |> :timer.sleep()
  	correct_master_node()  
  end  
  

   
end


