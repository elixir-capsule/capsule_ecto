defmodule Capsule.Ecto do
  def encapsulate(changeset, params, permitted, func) when is_function(func, 2),
    do:
      do_encapsulate(
        changeset,
        params,
        permitted,
        {func}
      )

  def encapsulate(changeset, params, permitted, mod, func_name),
    do:
      do_encapsulate(
        changeset,
        params,
        permitted,
        {mod, func_name}
      )

  defp do_encapsulate(changeset, params, permitted, encapsulation_args) do
    stringified_permitted = Enum.map(permitted, &to_string/1)

    Enum.reduce(params, changeset, fn {field, _} = params_pair, changeset ->
      with true <- Enum.member?(stringified_permitted, to_string(field)),
           %Capsule.Encapsulation{} = encapsulation <-
             do_encapsulate(encapsulation_args |> Tuple.append([params_pair, changeset])) do
        Ecto.Changeset.cast(changeset, %{field => encapsulation}, permitted)
      end
      |> case do
        false -> changeset
        %Ecto.Changeset{} = changeset -> changeset
      end
    end)
  end

  defp do_encapsulate({mod, func, args}), do: apply(mod, func, args)
  defp do_encapsulate({func, args}), do: apply(func, args)
end
