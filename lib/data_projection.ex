defmodule DataProjection do
  require Logger

  defmacro __using__(_opts) do
    quote do
      @before_compile DataProjection
      import DataProjection, only: [project: 1, project: 2]
      Module.register_attribute(__MODULE__, :projections, accumulate: true)
    end
  end

  defmacro __before_compile__(_env) do
    quote generated: true do
      def run_projection(data) when is_map(data) do
        case @projections do
          [] ->
            data

          projections ->
            projection =
              projections
              |> Enum.reverse()
              |> Enum.reduce(%{}, &__run_projection__(&1, data, &2))

            Map.put(data, :projection, projection)
        end
      end

      def __run_projection__(_, _data, acc), do: acc
    end
  end

  defmacro project(key) when is_atom(key) do
    raise ArgumentError, message: "DataProjection: #{key}. Missing the from option"
  end

  defmacro project(key, opts) when is_atom(key) and is_list(opts) do
    lenses = Keyword.get(opts, :from, [])
    projection_definition = {key, lenses}

    quote do
      @projections unquote(projection_definition)
      def __run_projection__(unquote(projection_definition), data, projection) do
        keys = DataProjection.create_access_keys(unquote(opts))
        resolver = DataProjection.get_resolver(unquote(opts))
        discard_when_nil = Keyword.get(unquote(opts), :discard_when_nil, false)

        case get_in(data, keys) do
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

  def create_access_keys(opts) do
    opts
    |> Keyword.get(:from, [])
    |> List.wrap()
    |> Enum.map(&Access.key/1)
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

  def atom_keys(list) when is_list(list) do
    Enum.map(list, &atom_keys/1)
  end

  def atom_keys(map) when is_map(map) do
    Enum.into(map, %{}, fn
      {key, value} when is_map(value) or is_list(value) -> {String.to_atom(key), atom_keys(value)}
      {key, value} -> {String.to_atom(key), value}
    end)
  end

  def atom_keys(item), do: item
end
