defmodule LensesTest do
  use ExUnit.Case

  test "project the shit" do
    expected = %{
      client_name: "United Contracting Company",
      contractor_first_name: "Chris",
      contractor_last_name: "Martin",
      email: "chris+201912231105@example.com",
      sender_name: "United Contracting Company",
      user_id: 1_003_114
    }

    result = Invitation.execute()

    assert expected == Map.get(result, :projection)
  end
end
