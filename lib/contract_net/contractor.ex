defmodule ContractNet.Contractor do
  use GenServer

  @impl true
  def init(opts \\ []) do
    {:ok,
     %{
       proposal: Keyword.fetch!(opts, :proposal),
       chosen: false
     }}
  end

  @impl true
  def handle_cast({:call_for_proposal, sender}, state) do
    GenServer.cast(sender, {:offer, self(), state.proposal})

    {:noreply, state}
  end
end
