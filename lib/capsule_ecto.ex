defmodule Capsule.Ecto do
  def upload(changeset, params, permitted, func, opts \\ []) when is_function(func, 2),
    do: do_upload(changeset, params, permitted, {func}, opts)

  def upload(changeset, params, permitted, mod, func_name),
    do: do_upload(changeset, params, permitted, {mod, func_name}, [])

  def upload(changeset, params, permitted, mod, func_name, opts),
    do: do_upload(changeset, params, permitted, {mod, func_name}, opts)

  defp do_upload(changeset, params, permitted, locator_args, opts) do
    required = Keyword.get(opts, :required, false)

    Enum.reduce(permitted, changeset, fn field, changeset ->
      with {_, _} = params_pair <-
             Enum.find(params, :missing, fn {k, _} -> to_string(k) == to_string(field) end),
           %Capsule.Locator{} = locator <-
             do_upload(locator_args |> Tuple.append([params_pair, changeset])) do
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
