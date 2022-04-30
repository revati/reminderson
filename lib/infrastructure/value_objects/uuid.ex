defmodule Infrastructure.UUID do
  use Ecto.Type
  defdelegate type(), to: Ecto.UUID
  defdelegate cast(value), to: Ecto.UUID
  defdelegate autogenerate(), to: Ecto.UUID
  def dump(value), do: {:ok, value}

  def load(<<_::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96>> = string) do
    {:ok, string}
  end

  def load(value) do
    Ecto.UUID.load(value)
  end
end
