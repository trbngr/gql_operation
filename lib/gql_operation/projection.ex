defmodule GqlOperation.Projection do
  require Logger
  alias GqlOperation.Projection

  defmacro project(key) when is_atom(key) do
    raise ArgumentError, message: "Projection: #{key}. Missing the from option"
  end

  defmacro project(key, opts) when is_atom(key) and is_list(opts) do
    lenses = Keyword.get(opts, :from, [])
    projection_definition = {key, lenses}

    quote generated: true do
      @projections unquote(projection_definition)
      def run_projection(unquote(projection_definition), data, projection) do
        lens = Projection.create_lens(unquote(opts))
        resolver = Projection.get_resolver(unquote(opts))
        discard_when_nil = Keyword.get(unquote(opts), :discard_when_nil, false)

        case Focus.view(lens, data) do
          {:error, _} ->
            projection

          nil ->
            projection

          view ->
            case resolver.(view) do
              nil ->
                unless discard_when_nil,
                  do: Map.put(projection, unquote(key), nil),
                  else: projection

              value ->
                Map.put(projection, unquote(key), value)
            end
        end
      end
    end
  end

  def create_lens(opts) do
    opts
    |> Keyword.get(:from, [])
    |> List.wrap()
    |> compose_lenses()
  end

  def get_resolver(opts) do
    id = fn x -> x end

    case Keyword.get(opts, :resolve) do
      nil ->
        id

      fun when is_function(fun, 1) ->
        fun

      _ ->
        Logger.warn("resolve is expected to be a function of 1 arity")
        id
    end
  end

  def compose_lenses([]), do: Lens.make_lens(:___not_found___)

  def compose_lenses([head | tail]) do
    Enum.reduce(tail, Lens.make_lens(head), &Focus.compose(&2, Lens.make_lens(&1)))
  end
end
