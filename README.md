# CapsuleEcto

Ecto integration for [Capsule](https://github.com/elixir-capsule/capsule)

[![hex package](https://img.shields.io/hexpm/v/capsule_ecto.svg)](https://hex.pm/packages/capsule_ecto)
[![CI status](https://github.com/elixir-capsule/capsule_ecto/workflows/CI/badge.svg)](https://github.com/elixir-capsule/capsulei_ecto/actions)

This package adds the following two features to support the use of Capsule with Ecto:

1. Custom Type
2. Changeset helper

## Capsule.Ecto.Type

In your Ecto schema specify your file field with the following type to get serialization of uploads (`Capsule.Locator`) to maps:

```
defmodule Attachment
  use Ecto.Schema

  schema "attachments" do
    field :file_data, Capsule.Ecto.Type
  end
end
```

## Capsule.Ecto.upload

Cast params to uploaded data with `Capsule.Ecto.upload`. In the style of Ecto.Multi, it accepts either an anonymous function or a module and function name, both with arity(2). The first argument passed will be a 2 element tuple representing the key/param pair and the second value will be the changeset.

It is expected to return either a success tuple with the `Locator` struct or the changeset. In the latter case the changeset will simply be passed on down the pipe.

Even if you want to extract some metadata and apply a validation after you store the file, then the anonymous function may be all you need:

  ```
  |> %Attachment{}
  |> Ecto.changeset.change()
  |> Capsule.Ecto.upload(%{"file_data" => some_upload}, [:file_data], fn {_field, upload}, changeset ->
      case Capsule.Storages.Disk.put(upload) do
        {:ok, id} -> %{id: id, storage: Capsule.Storages.Disk, metadata: %{yo: :dawg}}
        error_tuple -> add_error(changeset, "upload just...failed")
      end
  end)
  |> validate_attachment

  ```

However, if you want to do more complicated things with the upload before storing it (such as resizing, encrypting, etc) then creating a module is probably the way to go.

  ```
  |> %Attachment{}
  |> Ecto.changeset.change()
  |> Capsule.Ecto.upload(%{"file_data" => some_upload}, [:file_data], MyApp.Attacher, :attach)
  ```
---

## Upload cleanup

Since the file is written to disk as part of the changeset, you will probably want to do some cleanup depending on the error status. On success you may want to move the file from a temporary location to permanent storage (especially if the latter is in the cloud and costs a network request). On failure you may want to delete the file (unless you are handling that with some sort of periodic task).

One good option is to wrap your Repo operation in another function to handle both as asynchronous Tasks so they don't block the parent process:

  ```
  def create_attachment(user, attrs) do
  %Attachment{}
  |> Ecto.changeset.change()
  |> Capsule.Ecto.upload(attrs, [:file_data], MyApp.Attacher, :attach)
  |> Repo.insert()
  |> case do
    {:ok, attachment} = success_tuple ->
      Task.Supervisor.start_child(
        YourApp.Supervisor,
        fn -> Attachment.promote_upload(attachment) end
      )

      success_tuple

    {:error, %{changes: %{file_data: file_data}}} = error_tuple ->
      Task.Supervisor.start_child(
        YourApp.Supervisor,
        fn -> Disk.delete(file_data.id) end
      )

      error_tuple
  end
  ```

In this example, `Attachment.promote_upload(attachment)` would handle moving the file and updating the file data in the db. It uses `Multi` to ensure all operations succeed or fail together:

  ```
  def promote_upload(attachment) do
    Multi.new()
    |> Multi.run(:copy_file, fn _, _ ->
      NetworkStorage.put(attachment.file_data.id)
    end)
    |> Multi.update(:updated_schema, fn %{move_file: new_data} ->
      Attachment.changeset(attachment, %{file_data: new_data })
    end)
    |> Multi.run(:delete_old_file, fn _, _ ->
      Disk.delete(attachment.file_data.id)
    end)
    |> Repo.transaction()
  end
  ```

## Testing

Since Locators are serialized as plain maps, it is easy to stub out file operations in fixtures/factories by inserting data directly into the db without going through a changeset:

  ```
  %Attachment{
    file_data: %{
      id: "fake.jpg",
      metadata: %{name: "fake"}, size: 100
    }
  }
  |> Repo.insert!()
  ```

If you want to run tests on the actual file operations, you will need to make sure the id points to an actual file location that the configured storage understands.

Or, if you are using [CapsuleSupplement](https://github.com/elixir-capsule/supplement), you can configure your test environment to use the RAM storage:

  ```
  {:ok, id} = Capsule.Storages.RAM.put(some_upload)

  %Attachment{file_data: %{id: id, storage: Capsule.Storages.RAM}}
  |> Repo.insert!()
  ```

For maximum performance, I recommend creating a simple struct that implements the Upload protocol:

  ```
  defmodule Capsule.MockUpload do
    defstruct content: "Hi, I'm a file", name: "hi"

    defimpl Capsule.Upload do
      def contents(mock), do: {:ok, mock.content}

      def name(mock), do: mock.name
    end
  end
  ```
