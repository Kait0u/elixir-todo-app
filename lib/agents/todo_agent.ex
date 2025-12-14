defmodule TodoAgent do
  use Agent

  def start_link(_opts \\ []) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
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

  def print() do
    get_tasklist()
    |> Enum.reverse()
    |> Enum.map(&TaskInfo.to_string/1)
    |> Enum.each(fn task_str ->
      IO.puts(task_str)
    end)
  end

  # =======================================================
  #  UTILS
  # =======================================================

  @spec get_tasklist() :: list(TaskInfo.t())
  defp get_tasklist(), do: Agent.get(__MODULE__, & &1)

  @spec set_tasklist(list(TaskInfo.t())) :: :ok
  defp set_tasklist(new_tasklist), do: Agent.update(__MODULE__, fn _ -> new_tasklist end)
end
