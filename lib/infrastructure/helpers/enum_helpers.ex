defmodule EnumHelpers do
  use Boundary, deps: [], exports: []

  def key_type(map) when map_size(map) === 0, do: :atom

  def key_type(map) do
    Enum.reduce_while(map, nil, fn
      {key, _}, _ when is_binary(key) -> {:halt, :string}
      {key, _}, _ when is_atom(key) -> {:halt, :atom}
    end)
  end

  def keys(map) when is_map(map), do: Map.keys(map)
  def keys(list) when is_list(list), do: Keyword.keys(list)

  def take(map, keys) when is_map(map), do: Map.take(map, keys)
  def take(list, keys) when is_list(list), do: Keyword.take(list, keys)

  def get(map, key) when is_map(map), do: Map.get(map, key)
  def get(list, key) when is_list(list), do: Keyword.get(list, key)
end
