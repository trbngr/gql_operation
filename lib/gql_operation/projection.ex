defmodule GqlOperation.Projection do
  defmacro project(key) when is_atom(key) do
    raise ArgumentError, message: "Project #{key}. Missing the from option"
  end

  defmacro project(key, opts) when is_atom(key) do
    lenses = Keyword.get(opts, :from, [])
    resolve = Keyword.get(opts, :resolve)

    quote bind_quoted: [key: key, lenses: lenses, resolve: resolve] do
      @projections {key, [lenses: lenses, resolve: resolve]}
    end
  end

  def run_projections(data, projections, acc \\ %{})

  def run_projections(_data, [], acc), do: acc

  def run_projections(data, [{key, opts} | tail], acc) do
    resolver = Keyword.get(opts, :resolver, fn x -> x end)
    lens = compose_lenses(Keyword.get(opts, :lenses, []))

    projection =
      case Focus.view(lens, data) do
        {:error, _} -> acc
        view -> Map.put(acc, key, resolver.(view))
      end

    run_projections(data, tail, projection)
  end

  defp compose_lenses([head | tail]) do
    Enum.reduce(tail, Lens.make_lens(head), &Focus.compose(&2, Lens.make_lens(&1)))
  end
end
