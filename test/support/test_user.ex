defmodule Capsule.Ecto.Test.TestUser do
  use Ecto.Schema

  schema "app_users" do
    field(:attachment, Capsule.Ecto.Type)
  end
end
