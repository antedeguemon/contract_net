defmodule ContractNet.Manager do
  use GenServer

  @impl true
  def init(_) do
    {:ok,
     %{
       status: :idle,
       offers_sent: [],
       proposals_received: [],
       proposals_accepted: []
     }}
  end
end
