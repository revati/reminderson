defmodule Components.Directives do
  @types [:primary, :secondary, :success, :danger, :warning, :info, :light, :dark, :link]

  def type_directive(:link, raw, opts) do
    type_directive(:any, raw, Map.put(opts, :prefix, "link-"))
  end

  def type_directive(:button, raw, opts) do
    prefix = if Map.has_key?(raw, :outline), do: "btn-outline-", else: "btn-"

    type_directive(:any, raw, Map.put(opts, :prefix, prefix))
  end

  def type_directive(_element_type, raw, opts) do
    @types
    |> Enum.reduce_while(nil, fn type, nil ->
      if Map.get(raw, type, false), do: {:halt, type}, else: {:cont, nil}
    end)
    |> case do
      nil -> opts[:default] || hd(@types)
      type -> type
    end
    |> then(&{:append, :class, "#{opts[:prefix]}#{&1}"})
  end

  def click_directive(_element_type, raw, _opts) do
    IO.inspect(raw)
    click = Map.get(raw, :click, false)

    {:put, :phx_click, click}
  end

  def slots_directive(_element_type, raw, opts) do
    slots = opts[:slots] || [:inner_block]

    slots
    |> Enum.reduce([], fn slot, acc ->
      if Map.get(raw, slot, false), do: [{:put, slot, raw[slot]} | acc]
    end)
  end

  @sizes [:sm, :lg]
  def size_directive(elemet_type, raw, opts) when elemet_type in [:button, :close] do
    size_directive(:any, raw, Map.put(opts, :prefix, "btn-"))
  end

  def size_directive(_element_type, raw, opts) do
    @sizes
    |> Enum.reduce_while(nil, fn size, nil ->
      if Map.get(raw, size, false), do: {:halt, size}, else: {:cont, nil}
    end)
    |> case do
      nil -> []
      size -> {:append, :class, "#{opts[:prefix]}#{size}"}
    end
  end

  def disabled_directive(_element_type, raw, _opts) do
    if Map.get(raw, :disabled, false) do
      [{:put, :disabled, true}, {:put, :aria_disabled, true}, {:put, :tabindex, "-1"}]
    end
  end

  def active_directive(_element_type, raw, _opts) do
    if Map.get(raw, :active, false) do
      {:append, :class, "active"}
    end
  end

  def copy_assigns_directive(:button, raw, opts) do
    copy_assigns_directive(:any, raw, Map.put(opts, :only, [:class, :role]))
  end

  def copy_assigns_directive(:close, raw, opts) do
    copy_assigns_directive(:any, raw, Map.put(opts, :only, [:class]))
  end

  def copy_assigns_directive(_element_type, raw, opts) do
    (opts[:only] || [])
    |> Enum.reduce([], fn opt, acc ->
      action = if opt in [:class], do: :append, else: :put
      value = Map.get(raw, opt, false)

      if value, do: [{action, opt, value} | acc], else: acc
    end)
  end

  def button_group_directive(:button_group, raw, _opts) do
    class = if Map.get(raw, :vertical, false), do: "btn-group-vertical", else: "btn-group"

    {:append, :class, class}
  end
end
