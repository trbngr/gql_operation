defmodule GqlOperation do
  defmacro __using__(opts) do
    query_string = Keyword.get(opts, :query_string) || raise "query_string is a required option"
    is_list_response = Keyword.get(opts, :is_list_response, false)

    discard_response =
      case is_list_response do
        true -> false
        false -> Keyword.get(opts, :discard_response, false)
      end

    %{is_list_response: is_list_response, discard_response: discard_response} |> IO.inspect()

    quote generated: true, location: :keep do
      use DataProjection
      alias GqlOperation.Execution

      @spec execute() :: map()
      @spec execute(map() | keyword()) :: map()
      @spec execute(map() | keyword(), keyword()) :: map()

      def execute(variables \\ %{}, opts \\ []) when is_map(variables) do
        response = Execution.execute(unquote(query_string), variables, opts)

        data =
          case unquote(is_list_response) do
            true ->
              Enum.map(response, fn item ->
                %{projection: item_projection} = run_projection(item)
                item_projection
              end)

            false ->
              run_projection(response)
          end

        case unquote(discard_response) do
          true -> data.projection
          false -> data
        end
      end
    end
  end
end
