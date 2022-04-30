defmodule CRUD.EntityUpdated do
  use Infrastructure.Schema

  @derive Jason.Encoder
  mex_embedded_schema do
    mex_field :entity_id, Infrastructure.UUID
    mex_field :changes, :map
    mex_field :type, Infrastructure.Atom
  end
end
