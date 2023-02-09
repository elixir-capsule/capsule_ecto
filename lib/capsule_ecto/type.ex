defmodule Capsule.Ecto.Type do
  use Ecto.Type

  alias Capsule.{Locator}

  def type, do: :map

  def cast(%Locator{} = value), do: {:ok, value}
  def cast(value) when is_map(value), do: {:ok, struct(Locator, value)}
  def cast(_), do: :error

  def load(serialized_data) when is_map(serialized_data) do
    atomized_keys =
      for {k, v} <- serialized_data, into: %{} do
        {String.to_existing_atom(k), v}
      end

    {:ok, struct(Locator, atomized_keys)}
  end

  def dump(%Locator{} = locator), do: {:ok, locator |> Map.from_struct()}
  def dump(data) when is_map(data), do: {:ok, data}
  def dump(_), do: :error
end
