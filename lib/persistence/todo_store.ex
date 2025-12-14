defmodule TodoStore do
  @default_filename "store/todos.json"

  @enforce_keys [:path]
  defstruct [:path]

  @type t() :: %TodoStore{path: String.t()}

  def new(file_path \\ nil)

  def new(nil), do: new(default_path())

  def new(file_path) do
    %TodoStore{
      path: file_path
    }
  end

  @spec load(TodoStore.t()) :: list(TaskInfo.t())
  def load(%TodoStore{} = todo_store) do
    ensure_dir(todo_store.path)

    case File.read(todo_store.path) do
      {:ok, data} ->
        Jason.decode(data, keys: :atoms)
        |> ok_or_empty()
        |> Enum.map(& struct(TaskInfo, &1))
      {:error, :enoent} ->
        []
    end
  end

  @spec persist(TodoStore.t(), list(TaskInfo.t())) :: :ok
  def persist(%TodoStore{} = todo_store, data) do
    ensure_dir(todo_store.path)

    json = Jason.encode!(data, pretty: true)
    tmp = todo_store.path <> ".tmp"

    File.write!(tmp, json) # First save as .tmp to avoid data corruption
    File.rename!(tmp, todo_store.path) # Then tename it to the target file.
  end

  # =======================================================
  #  UTILS
  # =======================================================

  defp default_path() do
    escript_dir =
      :escript.script_name()
      |> Path.dirname()

    Path.join(escript_dir, @default_filename)
  end

  defp ok_or_empty({:ok, data}), do: data
  defp ok_or_empty(_), do: %{}

  defp ensure_dir(path) do
    path
    |> Path.dirname()
    |> File.mkdir_p!()
  end
end
