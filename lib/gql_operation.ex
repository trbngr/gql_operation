defmodule GqlOperation do
  defmacro __using__(opts) do
    query_string = Keyword.get(opts, :query_string) || raise "query_string is a required option"
    result = Keyword.get(opts, :result) || raise "need a source until this macro is done"

    quote bind_quoted: [mod: __MODULE__, result: result, query_string: query_string] do
      import GqlOperation.Projection, only: [project: 1, project: 2]

      Module.register_attribute(__MODULE__, :projections, accumulate: true)

      @before_compile mod
      @result result
    end
  end

  defmacro __before_compile__(_env) do
    quote generated: true do
      alias GqlOperation.Execution
      alias GqlOperation.Projection

      @spec execute(map() | keyword(), keyword()) :: map()

      def execute(variables \\ %{}, opts \\ [])

      def execute(variables, opts) when is_list(variables) do
        execute(Enum.into(variables, %{}), opts)
      end

      def execute(variables, opts) when is_map(variables) do
        data =
          @result
          |> Jason.decode!()
          |> Execution.atom_keys()
          |> Map.get(:data, %{})

        case @projections do
          [] ->
            data

          projections ->
            projection = Projection.run_projections(data, Enum.reverse(projections))
            Map.put(data, :projection, projection)
        end
      end
    end
  end
end
