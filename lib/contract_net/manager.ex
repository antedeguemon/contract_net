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

  defp reset_state(state) do
    state
    |> Map.put(:status, :idle)
    |> Map.put(:offers_sent, [])
    |> Map.put(:proposals_received, [])
  end
end
