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
    Enum.reduce(params, changeset, fn {field, _} = params_pair, changeset ->
      with true <- permitted_param?(field, permitted),
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

  defp permitted_param?(k, permitted) when is_atom(k),
    do: [k, k |> Atom.to_string()] |> Enum.any?(&(&1 in permitted))

  defp permitted_param?(k, permitted) when is_binary(k),
    do: [k, k |> String.to_existing_atom()] |> Enum.any?(&(&1 in permitted))
end
