defmodule Support.ListResponse do
  use GqlOperation,
    is_list_response: true,
    discard_response: true,
    query_string: ""

  project :new_name, from: [:name]
end
