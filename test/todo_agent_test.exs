defmodule TodoAgentTest do
  use ExUnit.Case

  test "Should start with an empty task list by default" do
    {:ok, _pid} = TodoAgent.start_link()
    assert TodoAgent.get_tasks() == []
  end

  test "Should start with an initial list of tasks" do
    initial_tasks = [
      %TaskInfo{id: 1, title: "Task 1", done?: false},
      %TaskInfo{id: 2, title: "Task 2", done?: true}
    ]

    {:ok, _pid} = TodoAgent.start_link(initial_tasks)
    assert TodoAgent.get_tasks() == initial_tasks
  end

  test "Should add a new task" do
    {:ok, _pid} = IdSequenceAgent.start_link()
    {:ok, _pid} = TodoAgent.start_link()

    TodoAgent.add_task("New Task")
    tasks = TodoAgent.get_tasks()

    assert length(tasks) == 1
    assert Enum.at(tasks, 0).title == "New Task"
    assert Enum.at(tasks, 0).done? == false
  end

  test "Should mark a task as done" do
    {:ok, _pid} = IdSequenceAgent.start_link()
    {:ok, _pid} = TodoAgent.start_link()

    TodoAgent.add_task("Task to be done")
    [task | _] = TodoAgent.get_tasks()

    TodoAgent.toggle_done(task.id)
    [updated_task | _] = TodoAgent.get_tasks()

    assert updated_task.done? == true
  end

  test "Should mark a task as not done" do
    {:ok, _pid} = IdSequenceAgent.start_link()
    {:ok, _pid} = TodoAgent.start_link()

    TodoAgent.add_task("Task to be undone")
    [task | _] = TodoAgent.get_tasks()

    # Mark as done first
    TodoAgent.toggle_done(task.id)
    # Then mark as not done
    TodoAgent.toggle_done(task.id)
    [updated_task | _] = TodoAgent.get_tasks()

    assert updated_task.done? == false
  end

  test "Should remove a task" do
    {:ok, _pid} = IdSequenceAgent.start_link()
    {:ok, _pid} = TodoAgent.start_link()

    TodoAgent.add_task("Task to be removed")
    [task | _] = TodoAgent.get_tasks()

    TodoAgent.delete_task(task.id)
    tasks = TodoAgent.get_tasks()

    assert length(tasks) == 0
  end

  test "Should not fail when marking a non-existent task as done" do
    {:ok, _pid} = TodoAgent.start_link()

    # Attempt to mark a non-existent task as done
    TodoAgent.toggle_done(999)

    # Ensure the task list is still empty
    assert TodoAgent.get_tasks() == []
  end

  test "Should not fail when removing a non-existent task" do
    {:ok, _pid} = TodoAgent.start_link()

    # Attempt to remove a non-existent task
    TodoAgent.delete_task(999)

    # Ensure the task list is still empty
    assert TodoAgent.get_tasks() == []
  end

  test "Should return 0 as max_id for an empty task list" do
    {:ok, _pid} = TodoAgent.start_link()
    assert TodoAgent.max_id() == 0
  end

  test "Should return the correct max_id for a non-empty task list" do
    {:ok, _pid} = TodoAgent.start_link([
      %TaskInfo{id: 2, title: "Task 2", done?: false},
      %TaskInfo{id: 5, title: "Task 5", done?: true},
      %TaskInfo{id: 3, title: "Task 3", done?: false}
    ])

    assert TodoAgent.max_id() == 5
  end
end
