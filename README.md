# Todo

A simple command-line todo manager written in Elixir.

(Part of my final assignment for Functional Programming class taken in 2025.)

Manage your tasks directly from the terminal. Supports adding, listing, completing, and removing tasks, with persistent storage in a JSON file.

---

## Installation - Building the Executable

This project supports building a standalone executable using escript.

```bash
mix deps.get
mix escript.build
```


This will create an executable named `todo` in the `./build` subdirectory, to be called something like this:

```bash
./build/todo ...
```

## Usage

```
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
```

## Examples

```bash
# Add a new task
./todo add "Buy milk"

# List all tasks
./todo list

# Mark a task as complete
./todo complete 3

# Remove a task
./todo remove 2

# Use a custom storage file
./todo --file todos.json list

# Show help
./todo help

```
