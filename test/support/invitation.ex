defmodule Invitation do
  use GqlOperation,
    query_string: """
    query data($user_id: ID!, $enrollment_id: ID!, $client_id: ID!, $from_contractor_id: ID!){
      user(id: $user_id){
        numericId
        firstName
        lastName
        email
        phones(type: MOBILE){
          number
        }
      }
      enrollment(id: $enrollment_id){
        client{
          name
        }
      }
      master: contractor(clientId: $client_id, id: $from_contractor_id){
        firstName
        lastName
      }
    }
    """

  project :client_name, from: [:enrollment, :client, :name]
  project :sender_name, from: [:enrollment, :client, :name]
  project :user_id, from: [:user, :numericId]
  project :email, from: [:user, :email]
  project :contractor_first_name, from: [:user, :firstName]
  project :contractor_last_name, from: [:user, :lastName]

  project :mobile_phone,
    from: [:user, :phones],
    resolve: fn
      [%{number: number} | _] -> number
      _ -> nil
    end

  project :sender_name,
    from: [:master],
    discard_when_nil: true,
    resolve: fn
      %{firstName: first_name, lastName: last_name} -> "#{first_name} #{last_name}"
      _ -> nil
    end
end
