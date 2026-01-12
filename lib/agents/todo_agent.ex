defmodule TodoAgent do
  @moduledoc """
  Manages the in-memory list of todo tasks using an Elixir Agent.

  `TodoAgent` provides functions to:

  * Add, delete, and toggle tasks
  * Retrieve all tasks
  * Compute task statistics
  * Print a formatted todo list summary

  Typically used by `TodoApp.CLI` to interact with task data.
  """

  use Agent

  @doc """
  Starts the TodoAgent with an optional initial task list.

  ## Parameters

    * `initial_state` – List of `%TaskInfo{}` structs (defaults to empty list)

  ## Returns

    * `{:ok, pid}` on success
    * `{:error, reason}` on failure
  """
  @spec start_link(list(TaskInfo.t())) :: {:ok, pid()} | {:error, any()}
  def start_link(initial_state \\ []) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  @doc """
  Returns the current list of tasks.

  ## Returns

    * List of `%TaskInfo{}` structs
  """
  @spec get_tasks() :: list(TaskInfo.t())
  def get_tasks(), do: get_tasklist()

  @doc """
  Adds a new task to the list.

  Can accept either a `%TaskInfo{}` struct or a string task name.

  ## Parameters

    * `task_info` – A `%TaskInfo{}` struct or task name string

  ## Returns

    * `:ok`
  """
  @spec add_task(TaskInfo.t()) :: :ok
  @spec add_task(String.t()) :: :ok
  def add_task(%TaskInfo{} = task_info) do
    get_tasklist()
    |> then(&[task_info | &1])
    |> set_tasklist()
  end

  def add_task(task_name) when is_binary(task_name) do
    TaskInfo.new(task_name)
    |> add_task()
  end

  @doc """
  Deletes a task by its ID.

  ## Parameters

    * `task_id` – ID of the task to remove

  ## Returns

    * `:ok`
  """
  @spec delete_task(pos_integer()) :: :ok | :task_not_found
  def delete_task(task_id) do
    # Check if the task to be deleted is the last one and if so - force-set the ID Generator
    List.last(get_tasklist())
    |> case do
      %TaskInfo{id: ^task_id} -> IdSequenceAgent.force_set(task_id)
      _ -> nil
    end

    get_tasklist()
    |> Enum.find(& &1.id == task_id)
    |> case do
      nil -> :task_not_found
      _ ->
        get_tasklist()
        |> Enum.reject(& &1.id == task_id)
        |> set_tasklist()
      end
  end

  @doc """
  Toggles the completion status of a task by ID.

  ## Parameters

    * `task_id` – ID of the task to toggle

  ## Returns

    * `:ok`
  """
  @spec toggle_done(pos_integer()) :: :ok | :task_not_found
  def toggle_done(task_id) do
    get_tasklist()
    |> Enum.find(& &1.id == task_id)
    |> case do
      nil -> :task_not_found
      _ ->
        get_tasklist()
        |> Enum.map(&if &1.id == task_id, do: TaskInfo.toggle_done(&1), else: &1)
        |> set_tasklist()
      end
  end

  @doc """
  Returns the maximum task ID currently in use.

  ## Returns

    * `pos_integer()` – Maximum ID, or 0 if the list is empty
  """
  @spec max_id() :: pos_integer()
  def max_id() do
    get_tasklist()
    |> Enum.map(& &1.id)
    |> then(&[0 | &1]) # 0 for empty list fallback
    |> Enum.max()
  end

  @doc """
  Prints the task list and summary to the console.

  Includes a header, task list, and totals (total tasks, done count, percent done).
  """
  @spec print() :: :ok
  def print() do
    summary = summarize()

    PrintUtils.print_separator()
    IO.puts("My TODOs")
    PrintUtils.print_separator()

    tasks = get_tasklist()
    if length(tasks) > 0 do
      tasks
      |> Enum.sort_by(& &1.id)
      |> Enum.map(&TaskInfo.to_string/1)
      |> Enum.each(&IO.puts/1)
    else
      IO.puts("Nothing on your list yet...")
    end

    PrintUtils.print_separator()
    IO.puts("TOTAL = #{summary.total}, DONE = #{summary.done} (#{summary.percent_done}%)")
    PrintUtils.print_separator()
  end

  # =======================================================
  #  UTILS
  # =======================================================

  @doc false
  @spec get_tasklist() :: list(TaskInfo.t())
  defp get_tasklist(), do: Agent.get(__MODULE__, & &1)

  @doc false
  @spec set_tasklist(list(TaskInfo.t())) :: :ok
  defp set_tasklist(new_tasklist), do: Agent.update(__MODULE__, fn _ -> new_tasklist end)

  @doc false
  @spec summarize() :: %{total: non_neg_integer(), done: non_neg_integer(), percent_done: float()}
  defp summarize() do
    count = get_tasklist() |> length()
    done_count = get_tasklist() |> Enum.count(& &1.done?)

    %{
      total: count,
      done: done_count,
      percent_done: if(count != 0, do: 100.0 * done_count / count, else: 100.0)
    }
  end
end
