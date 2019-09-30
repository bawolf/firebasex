defmodule Firebasex.KeyRegistryTest do
  use ExUnit.Case
  doctest Firebasex.KeyRegistry
  import Mocker

  test "key registry fetches values when needed" do
    mock(Firebasex.GoogleKeys)

    mock_reg = intercept(GoogleKeys, :fetch, [], with: fn -> %{"a" => "hello"} end)

    intercept(GoogleKeys, :fetch, [], with: fn -> %{"b" => "world"} end)

    # has by default
    assert {:ok, "hello"} == Firebasex.KeyRegistry.value("a")
    # fetched on second pass
    assert {:ok, "world"} == Firebasex.KeyRegistry.value("b")
    # no longer available. fails on second pass
    assert {:error, "google_signature_not_found"} == Firebasex.KeyRegistry.value("a")
    assert mock_reg |> was_called() == :"3 times"
  end
end
