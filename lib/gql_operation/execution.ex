defmodule GqlOperation.Execution do
  require Logger

  # def execute(query_string, variables, opts \\ []) when is_map(variables) do
  #   query_string
  #   |> Neuron.query(variables, opts)
  #   |> handle_response()
  # end

  # defp handle_response({:ok, %{status_code: 200, body: body}}) do
  #   body
  #   |> handle_body()
  #   |> atom_keys()
  # end

  # defp handle_response(other), do: %{}

  # defp handle_body(%{"data" => data}), do: data
  # defp handle_body(%{"errors" => _errors}), do: %{}
  # defp handle_body(other), do: %{}

  def atom_keys(map) do
    Enum.into(map, %{}, fn
      {key, value} when is_map(value) or is_list(value) -> {String.to_atom(key), atom_keys(value)}
      {key, value} -> {String.to_atom(key), value}
    end)
  end
end
