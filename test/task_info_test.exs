defmodule TaskInfoTest do
  use ExUnit.Case

  test "Should create a new TaskInfo with given title and generated ID" do
    {:ok, _pid} = IdSequenceAgent.start_link()
    task = TaskInfo.new("New Task")

    assert task.title == "New Task"
    assert task.id == 1
    assert task.done? == false
  end

  test "Should toggle the done? status of a TaskInfo" do
    task = %TaskInfo{id: 1, title: "Test Task", done?: false}
    toggled_task = TaskInfo.toggle_done(task)

    assert toggled_task.done? == true

    toggled_back_task = TaskInfo.toggle_done(toggled_task)
    assert toggled_back_task.done? == false
  end

  test "Should represent TaskInfo as string correctly" do
    task = %TaskInfo{id: 1, title: "Test Task", done?: false}
    assert TaskInfo.to_string(task) == "[ ] #1 - Test Task"

    done_task = %TaskInfo{id: 2, title: "Done Task", done?: true}
    assert TaskInfo.to_string(done_task) == "[X] #2 - Done Task"
  end
end
