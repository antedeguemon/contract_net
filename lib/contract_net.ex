defmodule ContractNet do
  alias ContractNet.{Contractor, Manager}

  def random_auction(opts \\ []) do
    {:ok, pid} = Manager.start_link()

    opts |> Keyword.get(:contractors, []) |> create_contractors(opts)

    Manager.start_auction(pid)
  end

  def create_contractors([], opts) do
    IO.inspect("Creating contractors")
    max_proposal = Keyword.get(opts, :max_proposal, 10_000)
    max_contractors = Keyword.get(opts, :max_contractors, :rand.uniform(100))

    Enum.map(0..max_contractors, fn i ->
      proposal = :rand.uniform(max_proposal)
      {:ok, _} = Contractor.start_link(proposal: proposal)
      IO.puts("Created " <> to_string(i) <> " with proposal " <> to_string(proposal))
    end)
  end

  def create_contractors(contractors, _) do
    Enum.each(contractors, fn {_, value} ->
      {:ok, _} = Contractor.start_link(proposal: value)
    end)
  end
end
