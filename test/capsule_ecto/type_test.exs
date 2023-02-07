defmodule Capsule.Ecto.TypeTest do
  use ExUnit.Case
  doctest Capsule.Ecto

  alias Capsule.Ecto.Type
  alias Capsule.Locator

  describe "type/1 with locator" do
    test "wraps locator in success tuple" do
      assert {:ok, %Locator{id: "test"}} = Type.cast(%Locator{id: "test", storage: "fake"})
    end
  end

  describe "type/1 with map" do
    test "converts map to locator and wraps in success tuple" do
      assert {:ok, %Locator{id: "test"}} = Type.cast(%{id: "test", storage: "fake"})
    end
  end

  describe "type/1 with anything else" do
    test "returns error" do
      assert :error = Type.cast("what")
    end
  end

  describe "load/1 when data is map with string keys" do
    test "converts map to locator and wraps in success tuple" do
      assert {:ok, %Locator{id: "test"}} = Type.load(%{"id" => "test"})
    end
  end

  describe "dump/1 when data is an locator" do
    test "converts locator to map and wraps in success tuple" do
      assert {:ok, %{id: "test"}} = Type.dump(%Locator{id: "test"})
    end
  end

  describe "dump/1 when data is a map" do
    test "wraps data in success tuple" do
      assert {:ok, %{id: "test"}} = Type.dump(%{id: "test"})
    end
  end

  describe "dump/1 with anything else" do
    test "returns error" do
      assert :error = Type.dump("what")
    end
  end
end
