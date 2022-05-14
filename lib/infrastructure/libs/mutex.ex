defmodule Infrastructure.Mutex do
  use Boundary, top_level?: true, deps: [Mutex], exports: []

  def lock(keys) when is_list(keys) do
    keys |> Enum.join(":") |> lock()
  end

  def lock(key) when is_binary(key) do
    case Mutex.lock(__MODULE__, key) do
      {:ok, _} -> :ok
      {:error, _} -> :error
    end
  end

  def unlock_all_from_caller() do
    Mutex.goodbye(__MODULE__)
  end
end
