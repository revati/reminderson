defmodule CRUD.UpdateEntity do
  use Infrastructure.Command

  mex_embedded_schema do
    mex_field(:entity_id, Infrastructure.UUID, validation: :required)
    mex_field(:contents, :map, validation: :required)
    mex_field(:type, Infrastructure.Atom, validation: :required)
  end

  defmacro __using__(_) do
    quote do
      use Infrastructure.Command
      alias EnumHelpers

      def changeset(params) do
        {entity_id, entity_fields} = extract_allowed_fields(params)
        crud_changeset = Infrastructure.Mex.Validator.validate(__MODULE__, entity_fields)

        params = %{
          entity_id: entity_id,
          contents: crud_changeset.changes,
          type: __MODULE__
        }

        params
        |> CRUD.UpdateEntity.changeset()
        |> ChangesetHelpers.unify_changesets(crud_changeset)
      end

      defp extract_allowed_fields(params) do
        entity_id = __MODULE__.entity_id()
        entity_fields = :meta |> __MODULE__.__schema__() |> EnumHelpers.keys()

        case EnumHelpers.key_type(params) do
          :atom -> {entity_id, entity_fields}
          :string -> {Atom.to_string(entity_id), Enum.map(entity_fields, &Atom.to_string/1)}
        end
        |> extract_allowed_fields(params)
      end

      defp extract_allowed_fields({entity_id, entity_fields}, params) do
        {EnumHelpers.get(params, entity_id), EnumHelpers.take(params, entity_fields)}
      end
    end
  end
end
