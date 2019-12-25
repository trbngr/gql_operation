defmodule Invitation do
  @query_string "some query or mutation"

  @mock_result """
  {
    "data": {
      "enrollment": {
        "client": {
          "name": "United Contracting Company"
        }
      },
      "master": {
        "firstName": "Caitlin",
        "lastName": "Swan"
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

  use GqlOperation, query_string: @query_string, result: @mock_result

  defp sender_name(%{firstName: first_name, lastName: last_name}) do
    "#{first_name} #{last_name}"
  end

  project :client_name, from: [:enrollment, :client, :name]
  project :sender_name, from: [:enrollment, :client, :name]
  project :user_id, from: [:user, :numericId]
  project :email, from: [:user, :email]
  project :contractor_first_name, from: [:user, :firstName]
  project :contractor_last_name, from: [:user, :lastName]

  # project :mobile_phone,
  #   from: [:user, :phones],
  #   resolve: fn
  #     [%{number: number} | _] -> number
  #     _ -> nil
  #   end

  # project :sender_name, from: :master, resolve: &sender_name/1
end
