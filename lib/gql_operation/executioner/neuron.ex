defmodule GqlOperation.Executioner.Neuron do
  @behaviour GqlOperation.Executioner

  def execute(query, variables, opts) do
    query
    |> Neuron.query(variables, opts)
    |> handle_response()
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    body
  end
end
