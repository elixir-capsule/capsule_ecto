defmodule Capsule.EctoTest do
  use ExUnit.Case
  doctest Capsule.Ecto

  alias Capsule.Locator
  alias Capsule.Ecto.Test.{TestUser, TestAttacher}

  describe "encapsulate/4" do
    test "adds the locator data to changeset" do
      assert %{changes: %{attachment: _}} =
               Ecto.Changeset.change(%TestUser{})
               |> Capsule.Ecto.upload(%{attachment: %{}}, [:attachment], fn _, _ ->
                 %Locator{}
               end)
    end

    test "adds adds error to attachment field" do
      %{errors: errors} =
        Ecto.Changeset.change(%TestUser{})
        |> Capsule.Ecto.upload(%{attachment: %{}}, [:attachment], fn _, changeset ->
          Ecto.Changeset.add_error(changeset, :attachment, "wrong")
        end)

      assert {"wrong", []} = errors[:attachment]
    end

    test "adds the locator data to changeset when params have binary keys" do
      assert %{changes: %{attachment: _}} =
               Ecto.Changeset.change(%TestUser{})
               |> Capsule.Ecto.upload(%{"attachment" => %{}}, [:attachment], fn _, _ ->
                 %Locator{}
               end)
    end
  end

  describe "uploader/4 with invalid param is ignored" do
    test "adds the locator data to changeset" do
      assert %{changes: %{}} =
               Ecto.Changeset.change(%TestUser{})
               |> Capsule.Ecto.upload(%{"what" => %{}}, [:attachment], fn _, _ ->
                 %Locator{}
               end)
    end
  end

  describe "upload/5" do
    test "adds the locator data to changeset" do
      assert %{changes: %{attachment: _}} =
               Ecto.Changeset.change(%TestUser{})
               |> Capsule.Ecto.upload(
                 %{attachment: %{}},
                 [:attachment],
                 TestAttacher,
                 :attach
               )
    end
  end
end
