defmodule GqlOperation do
  defmacro __using__(opts) do
    query_string = Keyword.get(opts, :query_string) || raise "query_string is a required option"

    quote bind_quoted: [mod: __MODULE__, query_string: query_string] do
      import GqlOperation.Projection, only: [project: 1, project: 2]

      Module.register_attribute(__MODULE__, :projections, accumulate: true)

      @before_compile mod
      @query_string query_string
    end
  end

  defmacro __before_compile__(_env) do
    quote generated: true do
      alias GqlOperation.Execution
      alias GqlOperation.Projection

      @spec execute(map() | keyword(), keyword()) :: map()

      def execute(variables \\ %{}, opts \\ []) when is_map(variables) do
        data = Execution.execute(@query_string, variables, opts)

        case @projections do
          [] ->
            data

          projections ->
            projection =
              projections
              |> Enum.reverse()
              |> Projection.run_projections(data)

            Map.put(data, :projection, projection)
        end
      end
    end
  end
end
