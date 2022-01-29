defmodule Components do
  :reminderson
  |> Application.compile_env!([__MODULE__, :components])
  |> Enum.each(fn
    {name, {module, function}} -> defdelegate unquote(name)(assigns), to: module, as: function
    {name, handler} -> defdelegate unquote(name)(assigns), to: handler
  end)

  :reminderson
  |> Application.compile_env!([__MODULE__, :actions])
  |> Enum.map(fn
    {name, {module, function}} ->
      :functions
      |> module.__info__()
      |> Keyword.get_values(function)
      |> Enum.each(fn
        1 -> defdelegate unquote(name)(one), to: module, as: function
        2 -> defdelegate unquote(name)(one, two), to: module, as: function
        3 -> defdelegate unquote(name)(one, two, three), to: module, as: function
      end)

    {name, module} ->
      :functions
      |> module.__info__()
      |> Keyword.get_values(name)
      |> Enum.each(fn
        1 -> defdelegate unquote(name)(one), to: module
        2 -> defdelegate unquote(name)(one, two), to: module
        3 -> defdelegate unquote(name)(one, two, three), to: module
      end)
  end)
end
