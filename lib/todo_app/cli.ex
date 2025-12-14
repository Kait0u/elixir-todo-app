defmodule TodoApp.CLI do
  @moduledoc """
  Command-line interface for **TodoApp**.

  This module is responsible for:

  * Parsing command-line arguments and options
  * Initializing application state (agents and storage)
  * Dispatching CLI commands
  * Persisting todos after command execution

  The CLI supports basic todo management commands such as adding,
  listing, completing, and removing tasks.

  ## Usage

      todo [options] <command> [arguments]

  ## Options

    * `-f`, `--file FILE` – Path to the todo storage file
    * `-h`, `--help` – Show help information

  ## Commands

    * `add "TASK TITLE"` – Add a new todo item
    * `list` – List all todo items
    * `complete ID` – Toggle completion status of a task
    * `remove ID` – Remove a task by ID
    * `help` – Show help message
  """

  @doc """
  Entry point for the TodoApp command-line interface.

  This function:

  1. Parses command-line options and arguments
  2. Loads todos from persistent storage
  3. Starts required agents (`TodoAgent`, `IdSequenceAgent`)
  4. Executes the requested command
  5. Persists the updated todo list

  ## Parameters

    * `args` – List of command-line arguments (typically `System.argv/0`)

  ## Returns

    * `:ok`
  """
  @spec main(list(String.t())) :: :ok
  def main(args) do
    {opts, args} = parse_options(args)

    todo_store = TodoStore.new(opts[:file])

    TodoAgent.start_link(TodoStore.load(todo_store))
    IdSequenceAgent.start_link(TodoAgent.max_id() + 1)

    handle_args(args)

    TodoStore.persist(todo_store, TodoAgent.get_tasks())
  end

  @doc false
  @spec parse_options(list(String.t())) :: {Keyword.t(), list(String.t())}
  defp parse_options(args) do
    {opts, rest, _invalid} =
      OptionParser.parse(args,
        switches: [file: :string, help: :boolean],
        aliases: [h: :help, f: :file]
      )

    {opts, rest}
  end

  @doc false
  defp handle_args(["add", title]) do
    TodoAgent.add_task(title)
    IO.puts("Added todo: \"#{title}\"")
  end

  @doc false
  defp handle_args(["list"]) do
    TodoAgent.print()
  end

  @doc false
  defp handle_args(["remove", id]) do
    TodoAgent.delete_task(String.to_integer(id))
    IO.puts("Deleted task ##{id}.")
  end

  @doc false
  defp handle_args(["complete", id]) do
    TodoAgent.toggle_done(String.to_integer(id))
    IO.puts("Updated task ##{id}.")
  end

  @doc false
  defp handle_args(["help"]) do
    print_help()
  end

  @doc false
  defp handle_args([]) do
    print_help()
  end

  @doc false
  defp handle_args(_) do
    IO.puts("Invalid command.\n")
    print_help()
  end

  @doc false
  defp print_help do
    IO.puts("""
    TodoApp — Simple command-line todo manager

    USAGE:
      todo [options] <command> [arguments]

    COMMANDS:
      add "TASK TITLE"      Add a new todo item
      list                  List all todo items
      remove ID             Remove a todo item by its ID
      complete ID           Toggle completion status of a todo item
      help                  Show this help message

    OPTIONS:
      -f, --file FILE       Path to the todo storage file
      -h, --help            Show this help message

    EXAMPLES:
      todo add "Buy milk"
      todo list
      todo complete 3
      todo remove 2
      todo --file todos.json list
    """)
  end
end
