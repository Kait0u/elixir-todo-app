defmodule TodoApp.CLI do
  def main(args) do
    {opts, args} = parse_options(args)

    todo_store = TodoStore.new(opts[:file])

    TodoAgent.start_link(TodoStore.load(todo_store))

    IdSequenceAgent.start_link(TodoAgent.max_id() + 1)

    handle_args(args)

    TodoStore.persist(todo_store, TodoAgent.get_tasks())
  end


  defp parse_options(args) do
    {opts, rest, _invalid} =
      OptionParser.parse(args,
        switches: [file: :string],
        aliases: []
      )

    {opts, rest}
  end

  defp handle_args(["add", title]) do
    TodoAgent.add_task(title)
    IO.puts("Added todo: #{title}")
  end

  defp handle_args(["list"]) do
    TodoAgent.print()
  end

  defp handle_args(["remove", id]) do
    TodoAgent.delete_task(String.to_integer(id))
    IO.puts("Deleted task ##{id}.")
  end

  defp handle_args(["complete", id]) do
    TodoAgent.toggle_done(String.to_integer(id))
    IO.puts("Updated task ##{id}.")
  end

  defp handle_args(_) do
    IO.puts("""
    Usage:
      todo add "Task name"
      todo list
    """)
  end
end
