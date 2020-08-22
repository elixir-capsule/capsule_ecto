defmodule Capsule.Ecto.TypeTest do
  use ExUnit.Case
  doctest Capsule.Ecto

  alias Capsule.Ecto.Type
  alias Capsule.Encapsulation

  describe "type/1 with encapsulation" do
    test "wraps encapsulation in success tuple" do
      assert {:ok, %Encapsulation{id: "test"}} = Type.cast(%Encapsulation{id: "test"})
    end
  end

  describe "type/1 with map" do
    test "converts map to encapsulation and wraps in success tuple" do
      assert {:ok, %Encapsulation{id: "test"}} = Type.cast(%{id: "test"})
    end
  end

  describe "type/1 with anything else" do
    test "returns error" do
      assert :error = Type.cast("what")
    end
  end

  describe "load/1 when data is map with string keys" do
    test "converts map to encapsulation and wraps in success tuple" do
      assert {:ok, %Encapsulation{id: "test"}} = Type.load(%{"id" => "test"})
    end
  end

  describe "dump/1 when data is an encapsulation" do
    test "converts encapsulation to map and wraps in success tuple" do
      assert {:ok, %{id: "test"}} = Type.dump(%Encapsulation{id: "test"})
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
