defmodule Capsule.Ecto.Test.TestAttacher do
  def attach({_field, _upload}, %Ecto.Changeset{}) do
    %Capsule.Locator{}
  end
end
