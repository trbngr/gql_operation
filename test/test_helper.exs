Mox.defmock(GqlOperation.MockExecutioner, for: GqlOperation.Executioner)

Application.put_env(
  :gql_operation,
  GqlOperation.Executioner,
  GqlOperation.MockExecutioner
)

ExUnit.start()
