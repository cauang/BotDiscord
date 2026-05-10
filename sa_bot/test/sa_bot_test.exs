defmodule SaBotTest do
  use ExUnit.Case
  doctest SaBot

  test "greets the world" do
    assert SaBot.hello() == :world
  end
end
