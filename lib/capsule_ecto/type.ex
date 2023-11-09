defmodule Capsule.Ecto.Type do
  use Ecto.Type

  alias Capsule.Locator

  def type, do: :map

  def cast(%Locator{} = value), do: {:ok, value}
  def cast(value) when is_map(value), do: Locator.new(value)
  def cast(_), do: :error

  def load(serialized_data) when is_map(serialized_data), do: Locator.new(serialized_data)

  def dump(%Locator{} = locator), do: {:ok, locator |> Map.from_struct()}
  def dump(_), do: :error
end
