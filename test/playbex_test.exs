defmodule PlaybexTest do
  use ExUnit.Case
  doctest Playbex

  test "greets the world" do
    assert Playbex.hello() == :world
  end
end
