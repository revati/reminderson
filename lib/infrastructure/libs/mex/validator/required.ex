defmodule Infrastructure.Mex.Validator.Required do
  def apply(changeset, meta, _dirty, _opts) do
    meta
    |> Enum.reduce(changeset, fn {name, opts}, changeset ->
      opts[:validation]
      |> List.wrap()
      |> Enum.find(false, fn
        {key, _value} -> key == :required
        key -> key == :required
      end)
      |> case do
        :required -> Ecto.Changeset.validate_required(changeset, name)
        {:required, opts} -> Ecto.Changeset.validate_required(changeset, name, opts)
        false -> changeset
      end
    end)
  end
end
