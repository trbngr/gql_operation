defmodule Invitation do
  @query_string "some query or mutation"

  use GqlOperation, query_string: @query_string

  project :client_name, from: [:enrollment, :client, :name]
  project :sender_name, from: [:enrollment, :client, :name]
  project :user_id, from: [:user, :numericId]
  project :email, from: [:user, :email]
  project :contractor_first_name, from: [:user, :firstName]
  project :contractor_last_name, from: [:user, :lastName]
  project :mobile_phone, from: [:user, :phones], resolve: :mobile_phone
  project :sender_name, from: :master, resolve: :sender_name

  def sender_name(%{firstName: first_name, lastName: last_name}) do
    "#{first_name} #{last_name}"
  end

  def mobile_phone([%{number: number} | _]), do: number
  def mobile_phone(_), do: nil
end
