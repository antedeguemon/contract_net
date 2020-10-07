defmodule ContractNet.Manager do
  use GenServer

  @impl true
  def init(opts \\ []) do
    group_name = Keyword.get(opts, :group_name, :agents)
    :pg2.create(group_name)

    {:ok,
     %{
       status: :idle,
       offers_sent: [],
       proposals_received: [],
       proposals_accepted: []
     }}
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

    {:noreply, %{state | state: updated_state}}
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
