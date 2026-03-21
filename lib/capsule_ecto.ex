defmodule Capsule.Ecto do
  @type changeset :: Ecto.Changeset.t()
  @type params :: map()
  @type permitted :: [atom()]
  @type opts :: [required: boolean()]

  @doc """
  Processes an upload for each permitted field found in params, calling the
  given function to produce a `Capsule.Locator` and casting it onto the changeset.

  The handler function receives `{field, value}` and the current changeset,
  and must return either a `Capsule.Locator` or an `Ecto.Changeset` (to add errors).

  ## Options

    * `:required` - when `true`, adds a validation error for any permitted field
      not present in params. Defaults to `false`.

  ## Examples

      %MySchema{}
      |> Ecto.Changeset.change()
      |> Capsule.Ecto.upload(params, [:avatar], fn {_field, upload}, _changeset ->
        Capsule.store(upload, MyStorage)
      end)

      %MySchema{}
      |> Ecto.Changeset.change()
      |> Capsule.Ecto.upload(params, [:avatar], MyUploader, :upload, required: true)

  """
  @spec upload(changeset(), params(), permitted(), (tuple(), changeset() -> Capsule.Locator.t() | changeset()), opts()) ::
          changeset()
  def upload(changeset, params, permitted, func, opts \\ [])

  def upload(changeset, params, permitted, func, opts) when is_function(func, 2),
    do: do_upload(changeset, params, permitted, {func}, opts)

  @spec upload(changeset(), params(), permitted(), module(), atom()) :: changeset()
  def upload(changeset, params, permitted, mod, func_name),
    do: do_upload(changeset, params, permitted, {mod, func_name}, [])

  @spec upload(changeset(), params(), permitted(), module(), atom(), opts()) :: changeset()
  def upload(changeset, params, permitted, mod, func_name, opts),
    do: do_upload(changeset, params, permitted, {mod, func_name}, opts)

  defp do_upload(changeset, params, permitted, locator_args, opts) do
    required = Keyword.get(opts, :required, false)

    Enum.reduce(permitted, changeset, fn field, changeset ->
      with {_, _} = params_pair <-
             Enum.find(params, :missing, fn {k, _} -> to_string(k) == to_string(field) end),
           %Capsule.Locator{} = locator <-
             do_upload(Tuple.insert_at(locator_args, tuple_size(locator_args), [params_pair, changeset])) do
        Ecto.Changeset.cast(changeset, %{field => locator}, permitted)
      end
      |> case do
        :missing -> maybe_validate_required(changeset, field, required)
        %Ecto.Changeset{} = changeset -> changeset
      end
    end)
  end

  defp maybe_validate_required(changeset, field, true),
    do: Ecto.Changeset.add_error(changeset, field, "can't be blank", validation: :required)

  defp maybe_validate_required(changeset, _field, false), do: changeset

  defp do_upload({mod, func, args}), do: apply(mod, func, args)
  defp do_upload({func, args}), do: apply(func, args)
end
