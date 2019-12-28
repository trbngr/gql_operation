defmodule GqlOperationTest do
  use ExUnit.Case
  import Mox

  @mock_result """
  {
    "data": {
      "enrollment": {
        "client": {
          "name": "United Contracting Company"
        }
      },
      "master": {
        "firstName": "Randy",
        "lastName": "Savage"
      },
      "user": {
        "email": "chris+201912231105@example.com",
        "firstName": "Chris",
        "lastName": "Martin",
        "numericId": 1003114,
        "phones": [
          {
            "number": "5555555555"
          }
        ]
      }
    }
  }
  """

  test "project the shit" do
    GqlOperation.MockExecutioner
    |> expect(:execute, fn _, _, _ ->
      @mock_result |> Jason.decode!() |> DataProjection.atom_keys()
    end)

    expected = %{
      client_name: "United Contracting Company",
      contractor_first_name: "Chris",
      contractor_last_name: "Martin",
      email: "chris+201912231105@example.com",
      sender_name: "Randy Savage",
      user_id: 1_003_114,
      mobile_phone: "5555555555"
    }

    result = Invitation.execute()

    assert expected == Map.get(result, :projection)
  end
end
