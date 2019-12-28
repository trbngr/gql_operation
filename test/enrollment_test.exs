defmodule EnrollmentTest do
  use ExUnit.Case
  import Mox

  @mock_result """
  {
    "data": {
      "enrollment": {
        "client": {
          "name": "Super Client"
        },
        "data": [
          {
            "name": "Activation.PublicCode",
            "value": "2cd4c436-599d"
          },
          {
            "name": "Application.Age_Provide_Proof_YN",
            "value": "Yes"
          },
          {
            "name": "Application.Contracted_With_Company_YN",
            "value": "No"
          },
          {
            "name": "Application.Driving_History",
            "value": "5 year over the road. Tank,van,flatbed, ect."
          },
          {
            "name": "Application.Employed_Or_Contracting_Not_How_Long",
            "value": "1 day"
          },
          {
            "name": "Application.Employed_Or_Contracting_Now_YN",
            "value": "No"
          },
          {
            "name": "Application.How_Long_at_Previous_Address",
            "value": "42 years"
          },
          {
            "name": "Application.Legal_to_Work_in_US",
            "value": "Yes"
          },
          {
            "name": "Application.Motor_Vehicle_Operation_Ever_Denied_Permit_Selection",
            "value": "No"
          },
          {
            "name": "Application.Motor_Vehicle_Operation_Ever_Suspended_Or_Revoked_Selection",
            "value": "No"
          },
          {
            "name": "Application.Resided_at_Current_Address_YN",
            "value": "Yes"
          },
          {
            "name": "Business.Name",
            "value": "KC DELIVERY"
          },
          {
            "name": "Business.Operating_Authority_Number",
            "value": "1111111"
          },
          {
            "name": "Business.Operating_Authority_Type",
            "value": "DOT"
          },
          {
            "name": "Business.Operating_Authority_YN",
            "value": "Yes"
          },
          {
            "name": "Contract.Role",
            "value": "driver"
          },
          {
            "name": "Contract.Type",
            "value": "master"
          },
          {
            "name": "Enrollment.BusinessTaxIdStatus",
            "value": "2"
          },
          {
            "name": "Enrollment.DriversLicenseCheckStatus",
            "value": "1"
          },
          {
            "name": "Enrollment.IndividualTaxIdStatus",
            "value": "1"
          },
          {
            "name": "Enrollment.IndividualTaxIdStatusSummary",
            "value": "The entered Tax Id has been verified."
          },
          {
            "name": "IdCheck.Result",
            "value": "0"
          },
          {
            "name": "IdCheck.VerificationTag",
            "value": null
          },
          {
            "name": "Individual.Address.City",
            "value": "ST FRANCISVLE"
          },
          {
            "name": "Individual.Address.Country",
            "value": "United States"
          },
          {
            "name": "Individual.Address.County",
            "value": "West Feliciana"
          },
          {
            "name": "Individual.Address.Line1",
            "value": "555 Somestreet Ave"
          },
          {
            "name": "Individual.Address.Line2",
            "value": ""
          },
          {
            "name": "Individual.Address.State",
            "value": "LA"
          },
          {
            "name": "Individual.Address.Zip",
            "value": "70775"
          },
          {
            "name": "Individual.DateOfBirth",
            "value": "7/30/1976"
          },
          {
            "name": "Individual.DriversLicense.Class",
            "value": "A"
          },
          {
            "name": "Individual.DriversLicense.Number",
            "value": "005555555"
          },
          {
            "name": "Individual.DriversLicense.State",
            "value": "LA"
          },
          {
            "name": "Individual.DriversLicense_ExpirationDate_Cal",
            "value": "2022-07-30"
          },
          {
            "name": "Individual.Email",
            "value": "someone@gmail.com"
          },
          {
            "name": "Individual.FirstName",
            "value": "Chris"
          },
          {
            "name": "Individual.LastName",
            "value": "Martin"
          },
          {
            "name": "Individual.MiddleName",
            "value": "Stephen"
          },
          {
            "name": "Individual.Names_Previously_Used",
            "value": ""
          },
          {
            "name": "Individual.Sex",
            "value": "male"
          },
          {
            "name": "SettlementProfileVerification.ExternalId",
            "value": "257068"
          },
          {
            "name": "SettlementProfileVerification.Status",
            "value": 1
          },
          {
            "name": "SettlementProfileVerification.Summary",
            "value": "Your profile has been found."
          }
        ],
        "package": {
          "contractRoles": [
            "driver"
          ],
          "contractType": "master",
          "name": "Contractor Enrollment"
        },
        "user": {
          "email": "ChrisMartin95@gmail.com",
          "firstName": "Chris",
          "lastName": "Martin",
          "phones": [
            {
              "number": "2252889735",
              "type": "mobile"
            }
          ]
        }
      }
    }
  }
  """

  test "test" do
    GqlOperation.MockExecutioner
    |> expect(:execute, fn _, _, _ ->
      @mock_result |> Jason.decode!() |> DataProjection.atom_keys()
    end)

    expected = %{
      individual: %{first_name: "Chris", gender: "Male", last_name: "Martin"},
      package_name: "Contractor Enrollment",
      user: %{
        email: "ChrisMartin95@gmail.com",
        firstName: "Chris",
        lastName: "Martin",
        phones: [%{number: "2252889735", type: "mobile"}]
      },
      business: %{authority_type: "DOT", name: "KC DELIVERY", authority_number: "1111111"},
      client_name: "Super Client",
      drivers_license: %{state: "LA", number: "005555555"},
      roles: ["driver"],
      type: "master"
    }

    projection =
      %{enrollment_id: "5662f977-ea18-4eb6-ae8f-050655065c1d"}
      |> Enrollment.execute()
      |> Map.get(:projection)

    assert expected == projection
  end
end
