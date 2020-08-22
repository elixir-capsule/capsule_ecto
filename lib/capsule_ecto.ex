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
    params_with_config =
      params
      |> Enum.map(fn {k, _} = params ->
        if permitted_param?(k, permitted) do
          {k, generate_encapsulation(encapsulation_args |> Tuple.append([params, changeset]))}
        else
          params
        end
      end)
      |> Enum.into(%{})

    Ecto.Changeset.cast(changeset, params_with_config, permitted)
  end

  defp generate_encapsulation({mod, func, args}), do: apply(mod, func, args)
  defp generate_encapsulation({func, args}), do: apply(func, args)

  defp permitted_param?(k, permitted) when is_atom(k),
    do: [k, k |> Atom.to_string()] |> Enum.any?(&(&1 in permitted))

  defp permitted_param?(k, permitted) when is_binary(k),
    do: [k, k |> String.to_existing_atom()] |> Enum.any?(&(&1 in permitted))
end
