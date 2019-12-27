defmodule GqlOperation.Projection do
  defmacro project(key) when is_atom(key) do
    raise ArgumentError, message: "Project #{key}. Missing the from option"
  end

  defmacro project(key, opts) when is_atom(key) do
    quote bind_quoted: [opts: opts, key: key] do
      lenses = Keyword.get(opts, :from, [])
      resolve = Keyword.get(opts, :resolve)

      resolve =
        case resolve do
          fun when is_atom(fun) -> {__MODULE__, fun}
          resolver -> resolver
        end

      @projections {key, [lenses: List.wrap(lenses), resolve: resolve]}
    end
  end

  def run_projections(projections, data, acc \\ %{})

  def run_projections([], _data, acc), do: acc

  def run_projections([{key, opts} | tail], data, acc) do
    lens =
      opts
      |> Keyword.get(:lenses, [])
      |> compose_lenses()

    resolver =
      case Keyword.get(opts, :resolve) do
        {mod, fun} when not is_nil(fun) -> fn x -> apply(mod, fun, [x]) end
        _ -> fn x -> x end
      end

    projection =
      case Focus.view(lens, data) do
        {:error, _} -> acc
        nil -> acc
        view -> Map.put(acc, key, resolver.(view))
      end

    run_projections(tail, data, projection)
  end

  defp compose_lenses([]), do: Lens.make_lens(:___not_found___)

  defp compose_lenses([head | tail]) do
    Enum.reduce(tail, Lens.make_lens(head), &Focus.compose(&2, Lens.make_lens(&1)))
  end
end
