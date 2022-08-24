defmodule Components.Bootstrap.Button do
  use Phoenix.Component

  @defined [
    type:
      {[:primary, :secondary, :success, :danger, :warning, :info, :light, :dark],
       &__MODULE__.apply_type/2, default: {:primary, true}},
    size: {[:lg, :sm], &__MODULE__.apply_size/2, []},
    disabled: {:disabled, &__MODULE__.apply_disabled/2, []}
  ]
  @defined_keys Enum.map(@defined, fn {key, _value} -> key end)

  attr :class, :string

  def button(assigns) do
    dir = [
      :type,
      :size,
      :disabled,
      {:phx_click, &apply_click/2, required: true}
    ]

    # directives = [
    #   {[:primary, :secondary, :success, :danger, :warning, :info, :light, :dark, :link],
    #    &apply_type/2, default: {:primary, true}},
    #   {[:lg, :sm], &apply_size/2, []},
    #   {:disabled, &apply_disabled/2, []}
    # ]

    ~H"""
    <.link {apply_directives(assigns, %{class: ["btn"]}, dir)}>
      <%= if assigns[:inner_block], do: render_slot(assigns[:inner_block]) %>
    </.link>
    """
  end

  # Each directive can be applied at most once
  defp apply_directives(assigns, base, directives) do
    directives =
      Enum.map(directives, fn dir ->
        dir
        |> case do
          {keys, callback, opts} -> {keys, callback, opts}
          {keys, opts} when is_list(opts) -> {keys, nil, opts}
          {keys, callback} when is_function(callback) -> {keys, callback, []}
          keys -> {keys, nil, []}
        end
        |> then(fn
          {keys, callback, opts} when keys in @defined_keys ->
            {d_keys, d_callback, d_opts} = @defined[keys]
            {d_keys, callback || d_callback, Keyword.merge(d_opts, opts)}

          {keys, nil, _opts} ->
            throw("directive [#{keys}] has no callback")

          {keys, callback, opts} ->
            {keys, callback, opts}
        end)
      end)

    #   {keys, callback, opts} -> {keys, callback, opts}
    #   key when key in @defined_keys -> @defined[key]
    #   {key, opts} when key in @defined_keys ->
    #     {keys, callback, }@defined[key]

    # end)
    assigns
    |> Enum.reduce(
      {base, directives},
      &apply_directive(&1, &2, assigns)
    )
    |> then(fn {attrs, reminding_directives} ->
      reminding_directives
      |> Enum.reduce(attrs, fn {_keys, callback, opts}, acc ->
        default = opts[:default]

        if default do
          callback.(default, assigns)
          |> List.wrap()
          |> Enum.reduce(acc, &Components.Helpers.handle_reducer_response/2)
        else
          acc
        end
      end)
    end)
  end

  defp apply_directive({_key, false}, {acc, directives}, _raw) do
    {acc, directives}
  end

  defp apply_directive({attr_key, attr_value}, {acc, directives}, raw) do
    directives
    |> pop_directive(attr_key)
    |> case do
      {nil, directives} ->
        {acc, directives}

      {{key, callback, _opts}, directives} ->
        {
          callback.({attr_key, attr_value}, raw)
          |> List.wrap()
          |> Enum.reduce(acc, &Components.Helpers.handle_reducer_response/2),
          directives
        }
    end
  end

  defp pop_directive(directives, attr_key) do
    directives
    |> Enum.find_index(fn
      {^attr_key, _callback, _opts} -> true
      {key, _callback, _opts} when is_list(key) -> attr_key in key
      _ -> false
    end)
    |> case do
      nil -> {nil, directives}
      index -> List.pop_at(directives, index)
    end
  end

  def apply_type({type, true}, raw) do
    if Map.has_key?(raw, :outline) do
      {:append, :class, "btn-outline-#{type}"}
    else
      {:append, :class, "btn-#{type}"}
    end
  end

  def apply_size({size, true}, _raw) do
    {:append, :class, "btn-#{size}"}
  end

  def apply_disabled({:disabled, value}, _raw) do
    if value do
      [{:put, :disabled, true}, {:put, :aria_disabled, true}, {:put, :tabindex, "-1"}]
    end
  end

  def apply_click({:phx_click, value}, _raw) do
    {:put, :phx_click, value}
  end
end
