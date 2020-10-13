defmodule ContractNet.Manager do
  use GenServer

  # Client

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  def start_auction(pid) do
    GenServer.cast(pid, :start_auction)
  end

  # Server

  @impl true
  def init(opts \\ []) do
    group_name = Keyword.get(opts, :group_name, :agents)
    :pg2.create(group_name)

    {:ok,
     %{
       status: :idle,
       offers_sent: [],
       proposals_received: [],
       proposals_accepted: [],
       group_name: group_name
     }}
  end

  @impl true
  def handle_cast(:start_auction, state) do
    offers_sent =
      state.group_name
      |> :pg2.get_members()
      |> Enum.map(fn pid ->
        GenServer.cast(pid, {:call_for_proposal, self()})
      end)

    {:noreply, %{state | status: :auction, offers_sent: offers_sent}}
  end

  @impl true
  def handle_cast({:offer, sender, value}, state) do
    updated_proposals = [{sender, value}] ++ state.proposals_received

    if received_all_proposals?(updated_proposals, state) do
      GenServer.cast(self(), :auction_ended)
    end

    {:noreply, %{state | proposals_received: updated_proposals}}
  end

  @impl true
  def handle_cast(:auction_ended, state) do
    {winner_pid, proposal} = select_winner(state.proposals_received)

    updated_state =
      state
      |> reset_state()
      |> Map.put(:proposals_accepted, [proposal] ++ state.proposals_accepted)

    GenServer.cast(winner_pid, :chosen)

    {:noreply, updated_state}
  end

  defp select_winner(proposals) do
    Enum.max_by(proposals, fn {_, value} -> value end)
  end

  defp reset_state(state) do
    state
    |> Map.put(:status, :idle)
    |> Map.put(:offers_sent, [])
    |> Map.put(:proposals_received, [])
  end

  defp received_all_proposals?(proposals, state) do
    length(proposals) == length(state.offers_sent)
  end
end
