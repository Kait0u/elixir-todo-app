defmodule TaskInfo do
  @done_marker "[X]"
  @pending_marker "[ ]"

  @enforce_keys [:id, :title]
  defstruct [:id, :title, done?: false]

  @type t :: %TaskInfo{id: integer, title: String.t(), done?: boolean}

  @spec new(String.t()) :: TaskInfo.t()
  def new(title) do
    %TaskInfo{
      id: IdSequenceAgent.generate(),
      title: title
    }
  end

  @spec toggle_done(TaskInfo.t()) :: TaskInfo.t()
  def toggle_done(%TaskInfo{done?: done?} = task_info) do
    %TaskInfo{task_info | done?: not done?}
  end

  @spec to_string(TaskInfo.t()) :: String.t()
  def to_string(task_info) do
    status_marker = if task_info.done?, do: @done_marker, else: @pending_marker
    "#{status_marker} ##{task_info.id} - #{task_info.title}"
  end
end
