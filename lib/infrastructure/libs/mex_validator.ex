defmodule MexValidator do
  use Boundary, deps: [Ecto.Changeset], exports: []

  import Ecto.Changeset

  defstruct cast: [],
            required: [],
            number: []

  def validate(command, params) when is_atom(command) do
    command
    |> struct()
    |> validate(params)
  end

  def validate(command, params) do
    ruleset = prepare_ruleset(command.__struct__)

    command
    |> cast(params, ruleset.cast)
    |> validate_required(ruleset.required)
    |> validate_field_rules(ruleset)
  end

  defp validate_field_rules(%Ecto.Changeset{} = changeset, %__MODULE__{} = ruleset) do
    ruleset
    |> Map.from_struct()
    |> Map.keys()
    |> List.delete(:cast)
    |> List.delete(:required)
    |> Enum.reduce(changeset, fn key, changeset ->
      ruleset
      |> Map.get(key)
      |> Enum.reduce(changeset, fn
        {field, rule}, changeset ->
          validate_field_rules(changeset, field, key, rule)

        field, changeset ->
          validate_field_rules(changeset, field, key, nil)
      end)
    end)

    # ruleset
    # |> Map.
  end

  defp validate_field_rules(%Ecto.Changeset{} = changeset, field, rule, opts) do
    IO.inspect({changeset, field, rule, opts})
    # validate_number(changeset, field, opts)
  end

  defp prepare_ruleset(command) do
    :meta
    |> command.__schema__()
    |> Enum.reduce(%__MODULE__{}, fn {field, meta}, ruleset ->
      apply_rule_field(ruleset, field, Keyword.get(meta, :validation, []))
    end)
  end

  defp apply_rule_field(%__MODULE__{} = ruleset, field, validation) do
    ruleset = apply_rule(ruleset, field, :cast)

    validation
    |> List.wrap()
    |> Enum.reduce(ruleset, &apply_rule(&2, field, &1))
  end

  defp apply_rule(%__MODULE__{} = ruleset, field, {rule, opts})
       when rule in [:number],
       do: Map.update!(ruleset, rule, &[{field, opts} | &1])

  defp apply_rule(%__MODULE__{} = ruleset, field, rule)
       when rule in [:required, :cast, :number],
       do: Map.update!(ruleset, rule, &[field | &1])

  defp apply_rule(%__MODULE__{} = ruleset, _field, {rule, _})
       when rule in [:required_if],
       do: ruleset
end
