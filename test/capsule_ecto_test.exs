defmodule Capsule.EctoTest do
  use ExUnit.Case
  doctest Capsule.Ecto

  alias Capsule.Encapsulation
  alias Capsule.Ecto.Test.{TestUser, TestAttacher}

  describe "encapsulate/4" do
    test "adds the encapsulation data to changeset" do
      assert %{changes: %{attachment: data}} =
               Ecto.Changeset.change(%TestUser{})
               |> Capsule.Ecto.encapsulate(%{attachment: %{}}, [:attachment], fn _, changeset ->
                 %Encapsulation{}
               end)
    end

    test "adds adds error to attachment field" do
      %{errors: errors} =
        Ecto.Changeset.change(%TestUser{})
        |> Capsule.Ecto.encapsulate(%{attachment: %{}}, [:attachment], fn _, changeset ->
          Ecto.Changeset.add_error(changeset, :attachment, "wrong")
        end)

      assert {"wrong", []} = errors[:attachment]
    end

    test "adds the encapsulation data to changeset when params have binary keys" do
      assert %{changes: %{attachment: data}} =
               Ecto.Changeset.change(%TestUser{})
               |> Capsule.Ecto.encapsulate(%{"attachment" => %{}}, [:attachment], fn _, _ ->
                 %Encapsulation{}
               end)
    end
  end

  describe "encapsulate/4 with invalid param is ignored" do
    test "adds the encapsulation data to changeset" do
      assert %{changes: %{}} =
               Ecto.Changeset.change(%TestUser{})
               |> Capsule.Ecto.encapsulate(%{"what" => %{}}, [:attachment], fn _, changeset ->
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
