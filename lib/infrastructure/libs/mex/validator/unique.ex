defmodule Infrastructure.Mex.Validator.Unique do
  def apply(changeset, meta, _dirty, command?: true) do
    meta
    |> Enum.reduce(changeset, fn {name, opts}, changeset ->
      opts[:validation]
      |> List.wrap()
      |> Enum.find(false, fn
        {key, _value} -> key == :unique
        key -> key == :unique
      end)
      |> case do
        :unique -> guard_uniqueness(changeset, name, [])
        {:unique, opts} -> guard_uniqueness(changeset, name, opts)
        false -> changeset
      end
    end)
  end

  def apply(changeset, meta, _dirty, _opts) do
    meta
    |> Enum.reduce(changeset, fn {name, opts}, changeset ->
      opts[:validation]
      |> List.wrap()
      |> Enum.find(false, fn
        {key, _value} -> key == :unique
        key -> key == :unique
      end)
      |> case do
        :unique -> Ecto.Changeset.unique_constraint(changeset, name, [])
        {:unique, opts} -> Ecto.Changeset.unique_constraint(changeset, name, opts)
        false -> changeset
      end
    end)
  end

  defp guard_uniqueness(changeset, field_name, opts) do
    id = Ecto.Changeset.fetch_change!(changeset, Keyword.get(opts, :id, :id))
    model = Keyword.get(opts, :model, changeset.data.__struct__)
    current_value = Ecto.Changeset.fetch_change!(changeset, field_name)

    case acquire_lock(model, id, field_name, current_value) do
      :ok -> changeset
      :error -> Ecto.Changeset.add_error(changeset, field_name, "Value must be unique", [])
    end
  end

  defp acquire_lock(model, id, field_name, current_value) do
    case Infrastructure.Repo.get_by(model, [{field_name, current_value}]) do
      %{id: ^id} ->
        :ok

      %{} ->
        :error

      nil ->
        Infrastructure.Mutex.lock([model, field_name, current_value])
    end
  end
end
