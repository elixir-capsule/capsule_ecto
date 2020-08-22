# CapsuleEcto

Ecto integration for [Capsule](https://github.com/elixir-capsule/capsule)

This package adds the following two features to support the use of Capsule with Ecto:

1. Custom Type

  Specify your file field with the following type to get serialization of encapsulated uploads to maps: `field :file_data, Capsule.Ecto.Type`

2. Changeset helper

  Cast params to encapsulated data with `Capsule.Ecto.encapsulate`. In the style of Ecto.Multi, it accepts either an anonymous function or a module and function name, with arity(2). The first argument will be a 2 element tuple representing the key/param pair and the second value will be the changeset. It is expected to return an `Encapsulation` struct.

  If you just want to store the file in some storage, and maybe extract some metadata then the anonymous function may be all you need:

  ```
  |> %Attachment{}
  |> Ecto.changeset.change()
  |> Capsule.Ecto.encapsulate(%{"file_data" => some_upload}, [:file_data], fn {_field, upload}, _changeset ->
      case Capsule.Storages.Disk.put(upload) do
        {:ok, cap} -> cap |> Capsule.add_metadata(%{yo: :dawg})
      end
  |> # Validate, etc
  ```

  However, if you want to do more complicated things with the upload before storing it (such as resizing, encrypting, etc) then creating a module is probably the way to go.
