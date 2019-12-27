defmodule GqlOperation.Executioner do
  @type query_string :: binary()
  @type variables :: map()
  @type opts :: keyword()

  @callback execute(query_string, variables, opts) :: map()
end
