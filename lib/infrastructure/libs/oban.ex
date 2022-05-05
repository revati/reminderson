defmodule Infrastructure.Oban do
  use Boundary, top_level?: true, deps: [Oban], exports: []

  def insert(changeset) do
    Oban.insert(__MODULE__, changeset)
  end

  def insert(multi, :reason = multi_name, changeset) do
    Oban.insert(__MODULE__, multi, multi_name, changeset)
  end

  def insert(multi, multi_name, changeset) do
    Oban.insert(__MODULE__, multi, multi_name, changeset)
  end
end
