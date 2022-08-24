defmodule Components do
  use Boundary, deps: [], exports: []

  defdelegate button(assigns), to: Components.Bootstrap.Button

  :reminderson
  |> Application.compile_env!([__MODULE__, :components])
  |> Enum.each(fn {name, element_config} ->
    {module, function, defaults} =
      case element_config do
        {module, function, defaults} ->
          {module, function, Macro.escape(Enum.into(defaults, %{}))}

        {module, defaults} when is_map(defaults) ->
          {module, name, Macro.escape(Enum.into(defaults, %{}))}

        {module, function} when is_atom(function) ->
          {module, function, Macro.escape(%{})}

        module ->
          {module, name, Macro.escape(%{})}
      end

    def unquote(name)(assigns) do
      assigns = Map.put(assigns, :__defaults__, unquote(defaults))
      apply(unquote(module), unquote(function), [assigns])
    end
  end)

  # :reminderson
  # |> Application.compile_env!([__MODULE__, :actions])
  # |> Enum.map(fn {name, element_config} ->
  #   {module, function, defaults} =
  #     case element_config do
  #       {module, function, defaults} -> {module, function, defaults}
  #       {module, defaults} when is_map(defaults) -> {module, name, defaults}
  #       {module, function} when is_atom(function) -> {module, function, %{}}
  #       module -> {module, name, %{}}
  #     end

  #   :functions
  #   |> module.__info__()
  #   |> Keyword.get_values(function)
  #   |> IO.inspect()
  #   |> Enum.each(fn
  #     1 ->
  #       def unquote(name)(assigns), do: apply(module, function, [Map.merge(assigns, defaults)])
  #   end)

  #   # {name, {module, function}} ->
  #   #   :functions
  #   #   |> module.__info__()
  #   #   |> Keyword.get_values(function)
  #   #   |> Enum.each(fn
  #   #     1 -> defdelegate unquote(name)(one), to: module, as: function
  #   #     2 -> defdelegate unquote(name)(one, two), to: module, as: function
  #   #     3 -> defdelegate unquote(name)(one, two, three), to: module, as: function
  #   #   end)

  #   # {name, module} ->
  #   #   :functions
  #   #   |> module.__info__()
  #   #   |> Keyword.get_values(name)
  #   #   |> Enum.each(fn
  #   #     1 -> defdelegate unquote(name)(one), to: module
  #   #     2 -> defdelegate unquote(name)(one, two), to: module
  #   #     3 -> defdelegate unquote(name)(one, two, three), to: module
  #   #   end)
  # end)
end
