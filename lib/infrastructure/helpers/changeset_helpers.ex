defmodule ChangesetHelpers do
  use Boundary, deps: [Ecto.Changeset], exports: []

  alias Ecto.Changeset

  def unify_changesets(one, two) do
    unify_changesets([one, two])
  end

  def unify_changesets(changesets) when is_list(changesets) do
    %{valid?: valid?, data: data, types: types, changes: changes, errors: errors} =
      extract_parts(changesets)

    %Changeset{
      valid?: valid?,
      data: data,
      types: types,
      changes: changes,
      errors: errors
    }
  end

  defp extract_parts(changesets) do
    # TODO: extract data, action and other stuff as well. Maybe some day
    empty = %{valid?: true, data: %{}, types: %{}, changes: %{}, errors: []}

    changesets
    |> Enum.reduce(empty, fn
      %{valid?: valid?, data: data, types: types, changes: changes, errors: errors}, acc ->
        acc
        |> Map.update!(:valid?, &(&1 && valid?))
        |> Map.update!(:types, &Map.merge(&1, types))
        |> Map.update!(:changes, &Map.merge(&1, changes))
        |> Map.update!(:errors, &Keyword.merge(&1, errors))
        |> then(fn
          %{data: %{} = existing_data} = acc when map_size(existing_data) === 0 ->
            %{acc | data: data}

          acc ->
            acc
        end)
    end)
  end
end
