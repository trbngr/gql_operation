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
  project :mobile_phone, from: [:user, :phones], resolve: &mobile_phone/1
  project :sender_name, from: [:master], discard_when_nil: true, resolve: &sender_name/1

  def mobile_phone([%{number: number} | _]), do: number
  def mobile_phone(_), do: nil

  def sender_name(%{firstName: first_name, lastName: last_name}), do: "#{first_name} #{last_name}"
  def sender_name(_), do: nil
end
