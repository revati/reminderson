defmodule CRUD.Aggregate do
  use Infrastructure.Schema

  alias CRUD.{EntityRemoved, EntityUpdated, RemoveEntity, UpdateEntity}

  mex_embedded_schema do
    mex_field(:entity_id, Infrastructure.UUID)
    mex_field(:contents, :map, default: %{})
    mex_field(:type, Infrastructure.Atom)
  end

  def execute(%__MODULE__{entity_id: entity_id}, %RemoveEntity{entity_id: entity_id}) do
    %CRUD.EntityRemoved{entity_id: entity_id}
  end

  def execute(%__MODULE__{entity_id: nil}, %RemoveEntity{}) do
    {:error, :cant_remove_non_existing_entity}
  end

  def execute(%__MODULE__{} = aggregate, %UpdateEntity{type: type} = command) do
    if is_nil(aggregate.type) || type === aggregate.type do
      type
      |> struct!(aggregate.contents)
      |> type.crud_changeset(command.contents)
      |> case do
        %{valid?: true, changes: changes} when map_size(changes) > 0 ->
          %EntityUpdated{entity_id: command.entity_id, changes: changes, type: type}

        %{valid?: true, changes: changes} when map_size(changes) == 0 ->
          nil

        %{valid?: false} = changeset ->
          {:error, changeset}
      end
    else
      {:error, :cant_change_entity_type}
    end
  end

  def apply(%__MODULE__{} = aggregate, %EntityUpdated{entity_id: entity_id, changes: changes}) do
    %{aggregate | entity_id: entity_id, contents: Map.merge(aggregate.contents, changes)}
  end

  def apply(%__MODULE__{}, %EntityRemoved{}) do
    %__MODULE__{}
  end
end
