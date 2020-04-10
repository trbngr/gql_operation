defmodule Enrollment do
  use GqlOperation,
    discard_response: false,
    query_string: """
      query data($enrollment_id: ID!){
        enrollment(id: $enrollment_id){
          client{
            name
          }
          package{
            name
            contractType
            contractRoles
          }
          data{
            name
            value
          }
          user{
            firstName
            lastName
            email
            phones{
              type
              number
            }
          }
        }
      }
    """

  project :client_name, from: [:enrollment, :client, :name]
  project :package_name, from: [:enrollment, :package, :name]
  project :type, from: [:enrollment, :package, :contractType]
  project :roles, from: [:enrollment, :package, :contractRoles]
  project :user, from: [:enrollment, :user]
  project :drivers_license, from: [:enrollment, :data], resolve: &read_drivers_license/1
  project :individual, from: [:enrollment, :data], resolve: &read_individual/1
  project :business, from: [:enrollment, :data], resolve: &read_business/1

  @data_fields [
    {"Individual.DriversLicense.Number", :number},
    {"Individual.DriversLicense.State", :state}
  ]
  def read_drivers_license(items), do: read_data(items, @data_fields)

  @data_fields [
    {"Individual.FirstName", :first_name, :title_case},
    {"Individual.LastName", :last_name, :title_case},
    {"Individual.Sex", :gender, :title_case}
  ]
  def read_individual(items), do: read_data(items, @data_fields)

  @data_fields [
    {"Business.Name", :name},
    {"Business.Operating_Authority_Number", :authority_number},
    {"Business.Operating_Authority_Type", :authority_type}
  ]
  def read_business(items), do: read_data(items, @data_fields)

  defp read_data(data_items, fields) do
    Enum.reduce(data_items, %{}, fn %{name: name, value: value}, acc ->
      case List.keyfind(fields, name, 0) do
        nil -> acc
        {_, field} -> Map.put(acc, field, value)
        {_, field, transformation} -> Map.put(acc, field, transform(transformation, value))
      end
    end)
  end

  defp transform(:title_case, <<char::utf8, rest::binary>>) do
    String.upcase(<<char::utf8>>) <> String.downcase(rest)
  end
end
