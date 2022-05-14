defmodule Infrastructure.Mex.Validator do
  @validators [
    Infrastructure.Mex.Validator.Cast,
    Infrastructure.Mex.Validator.Required,
    Infrastructure.Mex.Validator.Unique
  ]

  def validate(command, params, opts \\ [])

  def validate(command, params, opts) when is_atom(command) do
    command |> struct() |> validate(params, opts)
  end

  def validate(command, params, opts) when is_struct(params) do
    validate(command, Map.from_struct(params), opts)
  end

  def validate(%command_name{} = command, dirty, opts) when is_map(dirty) do
    meta = :meta |> command_name.__schema__() |> Enum.filter(&can_access_field?(&1, opts))

    @validators
    |> Enum.reduce(command, fn validator, changeset ->
      validator.apply(changeset, meta, dirty, opts)
    end)
  end

  defp can_access_field?({field, _}, except: except, only: only),
    do: field not in except and field in only

  defp can_access_field?({field, _}, except: except), do: field not in except
  defp can_access_field?({field, _}, only: only), do: field in only
  defp can_access_field?({_field, _}, _), do: true
end
