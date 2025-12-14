defmodule PrintUtils do
  @moduledoc """
  Utility functions for printing formatted output in the CLI.

  Currently provides a function to print a horizontal separator line
  of a fixed length using a configurable character.
  """

  @separator_char "="
  @separator_length 80

  @doc """
  Prints a horizontal separator line to the console.

  Uses the `@separator_char` repeated `@separator_length` times.

  ## Example

      iex> PrintUtils.print_separator()
      ========================================================================================
  """
  @spec print_separator() :: :ok
  def print_separator() do
    String.duplicate(@separator_char, @separator_length)
    |> IO.puts()
  end
end
