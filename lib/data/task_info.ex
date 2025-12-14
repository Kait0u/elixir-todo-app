defmodule TaskInfo do
  @moduledoc """
  Represents a single todo task.

  `TaskInfo` is a simple data structure that stores information about
  an individual task, including:

  * A unique numeric identifier
  * A task title
  * Completion status

  The module also provides helper functions for creating tasks,
  toggling their completion state, and rendering them as human-readable
  strings for CLI output.

  Tasks are JSON-serializable via `Jason.Encoder`.
  """

  @done_marker "[X]"
  @pending_marker "[ ]"

  @derive Jason.Encoder
  @enforce_keys [:id, :title]
  defstruct [:id, :title, done?: false]

  @typedoc """
  Task structure.

  ## Fields

    * `:id` – Unique task identifier
    * `:title` – Task description
    * `:done?` – Completion flag
  """
  @type t :: %TaskInfo{
          id: integer(),
          title: String.t(),
          done?: boolean()
        }

  @doc """
  Creates a new task with the given title.

  A unique task ID is generated automatically using `IdSequenceAgent`.

  ## Parameters

    * `title` – Title or description of the task

  ## Returns

    * A new `%TaskInfo{}` struct with `done?` set to `false`
  """
  @spec new(String.t()) :: TaskInfo.t()
  def new(title) do
    %TaskInfo{
      id: IdSequenceAgent.generate(),
      title: title
    }
  end

  @doc """
  Toggles the completion status of a task.

  If the task is marked as completed, it becomes pending.
  If it is pending, it becomes completed.

  ## Parameters

    * `task_info` – The task to update

  ## Returns

    * Updated `%TaskInfo{}` with inverted `done?` value
  """
  @spec toggle_done(TaskInfo.t()) :: TaskInfo.t()
  def toggle_done(%TaskInfo{done?: done?} = task_info) do
    %TaskInfo{task_info | done?: not done?}
  end

  @doc """
  Converts a task to a human-readable string.

  The string includes:

  * A status marker (`[X]` for completed, `[ ]` for pending)
  * The task ID
  * The task title

  ## Example

      iex> TaskInfo.to_string(%TaskInfo{id: 1, title: "Buy milk", done?: true})
      "[X] #1 - Buy milk"
  """
  @spec to_string(TaskInfo.t()) :: String.t()
  def to_string(task_info) do
    status_marker =
      if task_info.done?, do: @done_marker, else: @pending_marker

    "#{status_marker} ##{task_info.id} - #{task_info.title}"
  end
end
