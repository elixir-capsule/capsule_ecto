defmodule Capsule.Ecto do
  def upload(changeset, params, permitted, func) when is_function(func, 2),
    do:
      do_upload(
        changeset,
        params,
        permitted,
        {func}
      )

  def upload(changeset, params, permitted, mod, func_name),
    do:
      do_upload(
        changeset,
        params,
        permitted,
        {mod, func_name}
      )

  defp do_upload(changeset, params, permitted, locator_args) do
    stringified_permitted = Enum.map(permitted, &to_string/1)

    Enum.reduce(params, changeset, fn {field, _} = params_pair, changeset ->
      with true <- Enum.member?(stringified_permitted, to_string(field)),
           %Capsule.Locator{} = locator <-
             do_upload(locator_args |> Tuple.append([params_pair, changeset])) do
        Ecto.Changeset.cast(changeset, %{field => locator}, permitted)
      end
      |> case do
        false -> changeset
        %Ecto.Changeset{} = changeset -> changeset
      end
    end)
  end

  defp do_upload({mod, func, args}), do: apply(mod, func, args)
  defp do_upload({func, args}), do: apply(func, args)
end
