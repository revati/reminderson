defmodule Infrastructure.Mex.Validator.Cast do
  # TODO: For relationships/embeds
  @exclude_field_types []

  def apply(changeset, meta, dirty, _opts) do
    cast_fields =
      meta
      |> Stream.filter(fn {_name, opts} -> opts[:type] not in @exclude_field_types end)
      |> Stream.map(fn {name, _} -> name end)
      |> Enum.to_list()

    Ecto.Changeset.cast(changeset, dirty, cast_fields)
  end
end
