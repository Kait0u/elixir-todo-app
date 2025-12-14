defmodule TodoApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      IdSequenceAgent,
      TodoAgent
    ]

    opts = [
      strategy: :one_for_one,
      name: TodoApp.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end
