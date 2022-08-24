defmodule CRUD.EntityRemoved do
  use Infrastructure.Schema

  @derive Jason.Encoder
  mex_embedded_schema do
    mex_field(:entity_id, Infrastructure.UUID)
  end
end
