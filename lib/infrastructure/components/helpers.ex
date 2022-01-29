defmodule Components.Helpers do
  @types [:primary, :secondary, :success, :danger, :warning, :info, :light, :dark]

  use Phoenix.Component

  def assign_type(assigns, default_type \\ hd(@types)) do
    assigns
    |> assign_new(:type, fn ->
      assigns
      |> Enum.find(fn
        {key, true} when key in @types -> true
        _ -> false
      end)
      |> then(fn
        nil -> default_type
        {type, true} -> type
      end)
    end)
    |> guard_value(
      :type,
      &(&1 in @types),
      &"Component type provided is wrong #{inspect(&1)}. Allowd types: #{inspect(@types)}"
    )
    |> Map.drop(@types)
  end

  def assign_attribute(assigns, key, value, condition \\ true)

  def assign_attribute(assigns, key, value, condition) when is_function(condition, 1) do
    assign_attribute(assigns, key, value, condition.(assigns))
  end

  def assign_attribute(assigns, key, value, true) when is_function(value, 1) do
    assign_attribute(assigns, key, value.(assigns), true)
  end

  def assign_attribute(assigns, key, value, condition) do
    if condition do
      assign(assigns, key, value)
    else
      assigns
    end
  end

  def assign_extra_attributes(assigns, except) do
    assign(assigns, :extra, assigns_to_attributes(assigns, except))
  end

  def assign_class(assigns, class, condition \\ true)

  def assign_class(assigns, class, condition) when is_function(condition, 1) do
    assign_class(assigns, class, condition.(assigns))
  end

  def assign_class(assigns, class, condition)
      when condition in [false, nil, 0, "false", "null", "0"] do
    assigns
  end

  def assign_class(assigns, class, true) when is_function(class, 1) do
    assign_class(assigns, class.(assigns), true)
  end

  def assign_class(assigns, class, true) do
    existing_classes = List.wrap(assigns[:class] || "")

    assign(assigns, :class, [class | existing_classes])
  end

  def prepare_classes(classes) do
    classes |> Enum.reverse() |> class()
  end

  defp class(classes) do
    classes
    |> List.wrap()
    |> Enum.filter(fn
      {_, false} -> false
      _ -> true
    end)
    |> Enum.map(fn
      {value, _} -> combine_classes(value)
      value -> combine_classes(value)
    end)
    |> Enum.reject(&(&1 in [false, 0, ""]))
    |> Enum.join(" ")
  end

  def guard_value(assigns, field, allowed, error) do
    assigns[field]
    |> allowed.()
    |> unless do
      throw(error)
    else
      assigns
    end
  end

  defp combine_classes(value) when is_list(value), do: Enum.join(value, "-")
  defp combine_classes(value), do: value
end
