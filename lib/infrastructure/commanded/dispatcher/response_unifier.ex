defmodule Infrastructure.Dispatcher.ResponseUnifier do
  def normalize(pipeline) do
    data =
      pipeline.commands
      |> Enum.reverse()
      |> Enum.reduce([], &[{&1, Keyword.get(pipeline.data, &1) || {:error, :no_response}} | &2])

    all_success? = Enum.all?(data, &match?({_command, {:ok, _response}}, &1))

    cond do
      pipeline.multi? && all_success? -> {:ok, data}
      pipeline.multi? -> {:error, data}
      true -> pipeline.data[hd(pipeline.commands)]
    end
  end
end
