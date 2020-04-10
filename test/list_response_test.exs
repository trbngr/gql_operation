defmodule ListResponseTest do
  use ExUnit.Case
  import Mox

  @mock_result """
  {
    "data": [
      {"name": "chris"},
      {"name": "steve"},
      {"name": "luke"},
      {"name": "sarah"},
      {"name": "mike"}
    ]
  }
  """

  test "test" do
    GqlOperation.MockExecutioner
    |> expect(:execute, fn _, _, _ ->
      @mock_result |> Jason.decode!() |> DataProjection.atom_keys()
    end)

    expected = [
      %{new_name: "chris"},
      %{new_name: "steve"},
      %{new_name: "luke"},
      %{new_name: "sarah"},
      %{new_name: "mike"}
    ]

    projection = Support.ListResponse.execute()

    assert expected == projection
  end
end
