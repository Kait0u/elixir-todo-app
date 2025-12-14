defmodule IdSequenceAgentTest do
  use ExUnit.Case

  test "Should start and be ready to generate the first value" do
    IdSequenceAgent.start_link()
    assert IdSequenceAgent.peek_next() == 1
  end

  test "Should not advance when peeked" do
    IdSequenceAgent.start_link()

    peek_results =
      for _ <- 1 .. 10, do: IdSequenceAgent.peek_next()

    assert peek_results == List.duplicate(1, 10)
  end

  test "Should succesfully generate 10 numbers incrementally, and be ready to generate the 11th" do
    IdSequenceAgent.start_link()

    generated =
      for _ <- 1 .. 10, do: IdSequenceAgent.generate()

    assert generated == Range.to_list(1..10)
    assert IdSequenceAgent.peek_next() == 11
  end

  test "Should offer 1 again after a reset" do
    IdSequenceAgent.start_link()

    generated =
      for _ <- 1 .. 10, do: IdSequenceAgent.generate()

    outcome = IdSequenceAgent.reset()

    assert generated == Range.to_list(1..10)
    assert outcome == :ok
    assert IdSequenceAgent.peek_next() == 1
  end

  test "Should offer the value that has been force-set" do
    IdSequenceAgent.start_link()

    outcome = IdSequenceAgent.force_set(10)

    assert outcome == :ok
    assert IdSequenceAgent.peek_next() == 10
  end
end
