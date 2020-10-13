defmodule ContractNet.Contractor do
  use GenServer

  # Client

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  # Server

  @impl true
  def init(opts \\ []) do
    group_name = Keyword.get(opts, :group_name, :agents)
    :pg2.join(group_name, self())

    {:ok,
     %{
       proposal: Keyword.fetch!(opts, :proposal),
       chosen: false,
       group_name: group_name
     }}
  end

  @impl true
  def handle_cast({:call_for_proposal, sender}, state) do
    GenServer.cast(sender, {:offer, self(), state.proposal})

    {:noreply, state}
  end

  @impl true
  def handle_cast(:chosen, state) do
    {:noreply, %{state | chosen: true}}
  end
end
