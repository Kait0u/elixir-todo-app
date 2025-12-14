defmodule TodoStore do
  @moduledoc """
  Handles persistence of todo tasks to a JSON file.

  `TodoStore` is responsible for:

  * Loading tasks from a JSON file
  * Persisting tasks safely to disk
  * Managing a default storage location if none is provided

  This module ensures that the directory exists and performs
  atomic writes to prevent data corruption.
  """

  @default_filename "store/todos.json"

  @enforce_keys [:path]
  defstruct [:path]

  @typedoc """
  Represents a todo storage location.

  ## Fields

    * `:path` – Path to the JSON file where tasks are stored
  """
  @type t() :: %TodoStore{path: String.t()}

  @doc """
  Creates a new `TodoStore` struct.

  If `file_path` is `nil`, a default path (`store/todos.json`) relative
  to the escript directory will be used.

  ## Parameters

    * `file_path` – Optional path to the JSON file

  ## Examples

      iex> TodoStore.new("my_todos.json")
      %TodoStore{path: "my_todos.json"}

      iex> TodoStore.new()
      %TodoStore{path: "store/todos.json"} # default
  """
  def new(file_path \\ nil)
  def new(nil), do: new(default_path())
  def new(file_path), do: %TodoStore{path: file_path}

  @doc """
  Loads todo tasks from the JSON file.

  Returns an empty list if the file does not exist.

  ## Parameters

    * `todo_store` – The `TodoStore` struct representing the storage file

  ## Returns

    * List of `%TaskInfo{}` structs
  """
  @spec load(TodoStore.t()) :: list(TaskInfo.t())
  def load(%TodoStore{} = todo_store) do
    ensure_dir(todo_store.path)

    case File.read(todo_store.path) do
      {:ok, data} ->
        Jason.decode(data, keys: :atoms)
        |> ok_or_empty()
        |> Enum.map(&struct(TaskInfo, &1))

      {:error, :enoent} ->
        []
    end
  end

  @doc """
  Persists a list of todo tasks to the JSON file.

  Uses atomic writes: first saves to a `.tmp` file, then renames it
  to the target path to prevent data corruption.

  ## Parameters

    * `todo_store` – The `TodoStore` struct representing the storage file
    * `data` – List of `%TaskInfo{}` structs to save

  ## Returns

    * `:ok`
  """
  @spec persist(TodoStore.t(), list(TaskInfo.t())) :: :ok
  def persist(%TodoStore{} = todo_store, data) do
    ensure_dir(todo_store.path)

    json = Jason.encode!(data, pretty: true)
    tmp = todo_store.path <> ".tmp"

    File.write!(tmp, json)         # Save to temp file
    File.rename!(tmp, todo_store.path) # Rename to target file
  end

  # =======================================================
  #  UTILS
  # =======================================================

  @doc false
  defp default_path() do
    escript_dir =
      :escript.script_name()
      |> Path.dirname()

    Path.join(escript_dir, @default_filename)
  end

  @doc false
  defp ok_or_empty({:ok, data}), do: data
  defp ok_or_empty(_), do: %{}

  @doc false
  defp ensure_dir(path) do
    path
    |> Path.dirname()
    |> File.mkdir_p!()
  end
end
