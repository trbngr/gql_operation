defmodule GqlOperation.Execution do
  require Logger

  def execute(query_string, variables, opts \\ []) when is_map(variables) do
    executioner =
      Application.get_env(
        :gql_operation,
        GqlOperation.Executioner,
        GqlOperation.Executioner.Neuron
      )

    query_string
    |> executioner.execute(variables, opts)
    |> handle_body()
    |> atom_keys()
  end

  defp handle_body(%{"data" => data}), do: data
  defp handle_body(%{"errors" => _errors}), do: %{}
  defp handle_body(_other), do: %{}

  defp atom_keys(list) when is_list(list) do
    Enum.map(list, &atom_keys/1)
  end

  defp atom_keys(map) when is_map(map) do
    Enum.into(map, %{}, fn
      {key, value} when is_map(value) or is_list(value) -> {String.to_atom(key), atom_keys(value)}
      {key, value} -> {String.to_atom(key), value}
    end)
  end
end
