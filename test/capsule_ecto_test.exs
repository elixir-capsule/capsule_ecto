defmodule Capsule.EctoTest do
  use ExUnit.Case
  doctest Capsule.Ecto

  alias Capsule.Encapsulation
  alias Capsule.Ecto.Test.{TestUser, TestAttacher}

  describe "encapsulate/4" do
    test "adds the encapsulation data to changeset" do
      assert %{changes: %{attachment: data}} =
               Ecto.Changeset.change(%TestUser{})
               |> Capsule.Ecto.encapsulate(%{attachment: %{}}, [:attachment], fn _field, _param ->
                 %Encapsulation{}
               end)
    end

    test "adds the encapsulation data to changeset when params have binary keys" do
      assert %{changes: %{attachment: data}} =
               Ecto.Changeset.change(%TestUser{})
               |> Capsule.Ecto.encapsulate(%{"attachment" => %{}}, [:attachment], fn _field,
                                                                                     _param ->
                 %Encapsulation{}
               end)
    end
  end

  describe "encapsulate/5" do
    test "adds the encapsulation data to changeset" do
      assert %{changes: %{attachment: data}} =
               Ecto.Changeset.change(%TestUser{})
               |> Capsule.Ecto.encapsulate(
                 %{attachment: %{}},
                 [:attachment],
                 TestAttacher,
                 :attach
               )
    end
  end
end
