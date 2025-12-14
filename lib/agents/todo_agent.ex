defmodule TodoAgent do
  use Agent

  @spec start_link(list(TaskInto.t())) :: {:error, any()} | {:ok, pid()}
  def start_link(initial_state \\ []) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  @spec get_tasks() :: list(TaskInfo.t())
  def get_tasks(), do: get_tasklist()

  @spec add_task(TaskInfo.t()) :: :ok
  @spec add_task(String.t()) :: :ok

  def add_task(%TaskInfo{} = task_info) do
    get_tasklist()
    |> then(& [task_info | &1])
    |> set_tasklist()
  end

  def add_task(task_name) when is_binary(task_name) do
    TaskInfo.new(task_name)
    |> add_task()
  end

  @spec delete_task(pos_integer()) :: :ok
  def delete_task(task_id) do
    get_tasklist()
    |> Enum.reject(& &1.id == task_id)
    |> set_tasklist()
  end

  @spec toggle_done(pos_integer()) :: :ok
  def toggle_done(task_id) do
    get_tasklist()
    |> Enum.map(& if &1.id == task_id, do: TaskInfo.toggle_done(&1), else: &1)
    |> set_tasklist()
  end

  @spec max_id() :: pos_integer()
  def max_id() do
    get_tasklist()
    |> Enum.map(& &1.id)
    |> then(& [0 | &1]) # 0 for compatibility with empty stuff (will be increased to 1 via +1 when used)
    |> Enum.max()
  end

  @spec print() :: :ok
  def print() do
    summary = summarize()

    # Start printing

    PrintUtils.print_separator()
    IO.puts("My TODOs")
    PrintUtils.print_separator()

    tasks = get_tasklist()
    if length(tasks) > 0 do
      tasks
      |> Enum.reverse()
      |> Enum.map(&TaskInfo.to_string/1)
      |> Enum.each(fn task_str ->
        IO.puts(task_str)
      end)
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

  @spec get_tasklist() :: list(TaskInfo.t())
  defp get_tasklist(), do: Agent.get(__MODULE__, & &1)

  @spec set_tasklist(list(TaskInfo.t())) :: :ok
  defp set_tasklist(new_tasklist), do: Agent.update(__MODULE__, fn _ -> new_tasklist end)

  @spec summarize() :: %{total: non_neg_integer(), done: non_neg_integer(), percent_done: float()}
  defp summarize() do
    count =
      get_tasklist()
      |> then(&length/1)

    done_count =
      get_tasklist()
      |> Enum.count(&(&1.done?))

    %{
      total: count,
      done: done_count,
      percent_done: (if count != 0, do: 100.0 * done_count / count, else: 100.0)
    }
  end
end
