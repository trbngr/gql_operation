defmodule GqlOperation do
  defmacro __using__(opts) do
    query_string = Keyword.get(opts, :query_string) || raise "query_string is a required option"
    discard_response = Keyword.get(opts, :discard_response, false)

    quote generated: true do
      use DataProjection
      alias GqlOperation.Execution

      @spec execute() :: map()
      @spec execute(map() | keyword()) :: map()
      @spec execute(map() | keyword(), keyword()) :: map()

      def execute(variables \\ %{}, opts \\ []) when is_map(variables) do
        data =
          unquote(query_string)
          |> Execution.execute(variables, opts)
          |> run_projection()

        case unquote(discard_response) do
          true -> data.projection
          false -> data
        end
      end
    end
  end
end
