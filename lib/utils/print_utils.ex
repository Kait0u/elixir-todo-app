defmodule PrintUtils do
  @separator_char "="
  @separator_length 80

  def print_separator() do
    IO.puts(String.duplicate(@separator_char, @separator_length))
  end
end
