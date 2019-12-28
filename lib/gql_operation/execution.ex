defmodule GqlOperation.Execution do
  require Logger

  def execute(query_string, variables, opts \\ [])

  def execute(query_string, variables, opts) when is_list(variables) do
    execute(query_string, Enum.into(variables, %{}), opts)
  end

  def execute(query_string, variables, opts) when is_map(variables) do
    executioner =
      Application.get_env(
        :gql_operation,
        GqlOperation.Executioner,
        GqlOperation.Executioner.Neuron
      )

    query_string
    |> executioner.execute(variables, opts)
    |> handle_body()
  end

  defp handle_body(%{"data" => data}), do: data
  defp handle_body(%{"errors" => _errors}), do: %{}
  defp handle_body(%{data: data}), do: data
  defp handle_body(%{errors: _errors}), do: %{}
  defp handle_body(_other), do: %{}
end
