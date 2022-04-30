defmodule Infrastructure.EventSerializer do
  def serialize(term) when is_struct(term) do
    :dump
    |> term.__struct__.__schema__()
    |> Enum.reduce(%{}, fn {field, {_, type}}, acc ->
      case Ecto.Type.dump(type, Map.get(term, field)) do
        {:ok, value} -> Map.put(acc, field, value)
      end
    end)
    |> Jason.encode!()
  end

  def serialize(term) when is_map(term) do
    term
    |> Commanded.Serialization.JsonSerializer.serialize()
  end

  def deserialize(binary, type: type) do
    fields = Jason.decode!(binary, keys: :atoms!)
    model = String.to_existing_atom(type)

    params =
      :dump
      |> model.__schema__()
      |> Enum.reduce(%{}, fn {field, {_, type}}, acc ->
        # TODOL Should use load instead of cast
        case Ecto.Type.cast(type, Map.get(fields, field)) do
          {:ok, value} -> Map.put(acc, field, value)
        end
      end)

    struct(model, params)
  end

  def deserialize(binary, config) do
    binary
    |> Commanded.Serialization.JsonSerializer.deserialize(config)
  end
end
