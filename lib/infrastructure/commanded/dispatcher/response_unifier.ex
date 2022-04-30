defmodule Infrastructure.Dispatcher.ResponseUnifier do
  def normalize(:ok), do: :ok

  def normalize({status, response}) when is_list(response) do
    cond do
      Enum.all?(response, &match?({_, :ok}, &1)) ->
        :ok

      Enum.all?(response, &match?({_, %Ecto.Changeset{}}, &1)) ->
        {status,
         response
         |> Enum.map(&elem(&1, 1))
         |> Enum.reduce(&ChangesetHelpers.unify_changesets/2)}

      true ->
        {status, response}
    end
  end

  def normalize(all), do: all
end
