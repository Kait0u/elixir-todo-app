defmodule IdSequenceAgent do
  @moduledoc """
  Manages a global sequence of unique task IDs using an Elixir Agent.

  This agent provides:

  * Generating sequential IDs for tasks
  * Peeking at the next ID without incrementing
  * Forcing or resetting the next ID value
  * Checking if the agent is running

  Typically used by `TaskInfo.new/1` to assign unique IDs automatically.
  """

  use Agent

  @initial_next_value 1

  @doc """
  Starts the ID sequence agent.

  ## Parameters

    * `initial_next_value` – Optional integer to start the sequence from
      (defaults to `1`)

  ## Returns

    * `{:ok, pid}` on success
  """
  def start_link(initial_next_value \\ @initial_next_value) do
    Agent.start_link(fn -> initial_next_value end, name: __MODULE__)
  end

  @doc """
  Returns the next available ID without incrementing the sequence.

  ## Returns

    * `pos_integer()` – The next ID
  """
  @spec peek_next() :: pos_integer()
  def peek_next() do
    Agent.get(__MODULE__, & &1)
  end

  @doc """
  Generates a new unique ID and increments the sequence.

  ## Returns

    * `pos_integer()` – The newly generated ID
  """
  @spec generate() :: pos_integer()
  def generate() do
    Agent.get_and_update(__MODULE__, & {&1, &1 + 1})
  end

  @doc """
  Forces the next ID to a specific value.

  ## Parameters

    * `new_next` – The next ID to use

  ## Returns

    * `:ok`
  """
  @spec force_set(pos_integer()) :: :ok
  def force_set(new_next) do
    Agent.update(__MODULE__, fn _ -> new_next end)
  end

  @doc """
  Resets the ID sequence back to the initial value (default `1`).

  ## Returns

    * `:ok`
  """
  @spec reset() :: :ok
  def reset() do
    Agent.update(__MODULE__, fn _ -> @initial_next_value end)
  end

  @doc """
  Checks whether the ID sequence agent is currently running.

  ## Returns

    * `true` if running, `false` otherwise
  """
  @spec running?() :: boolean()
  def running?() do
    case Process.whereis(__MODULE__) do
      nil -> false
      _ -> true
    end
  end
end
