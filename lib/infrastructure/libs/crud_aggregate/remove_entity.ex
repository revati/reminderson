defmodule CRUD.RemoveEntity do
  use Infrastructure.Command

  mex_embedded_schema do
    mex_field(:entity_id, Infrastructure.UUID)
  end
end
