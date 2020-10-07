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
end
