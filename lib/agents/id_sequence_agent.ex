defmodule IdSequenceAgent do
  use Agent

  @initial_next_value 1

  def start_link(_opts \\ []) do
    Agent.start_link(fn -> @initial_next_value end, name: __MODULE__)
  end

  @spec peek_next() :: pos_integer()
  def peek_next() do
    Agent.get(__MODULE__, & &1)
  end

  @spec generate() :: pos_integer()
  def generate() do
    Agent.get_and_update(__MODULE__, & {&1, &1 + 1})
  end

  @spec force_set(pos_integer()) :: :ok
  def force_set(new_next) do
    Agent.update(__MODULE__, fn _ -> new_next end)
  end

  @spec reset() :: :ok
  def reset() do
    Agent.update(__MODULE__, fn _ -> @initial_next_value end)
  end

  @spec running?() :: boolean
  def running?() do
    case Process.whereis(__MODULE__) do
      nil -> false
      _ -> true
    end
  end
end
