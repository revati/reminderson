defmodule Components.Bootstrap.ButtonNew do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  alias Phoenix.HTML.Form
  alias RemindersonWeb.ErrorHelpers

  defp compute_static(assigns, attributes) do
    computed = Map.get(assigns, :__computed__, %{__changed__: nil})

    if should_compute?(assigns, computed, :static, []) do
      assign(assigns, :__computed__, assign(computed, :static, attributes))
    end
  end

  defp compute_new(assigns, key, opts \\ []) when is_list(opts) do
    computed = Map.get(assigns, :__computed__, %{__changed__: nil})

    if should_compute?(assigns, computed, key, opts) do
      default = {opts[:default] || false, %{value: opts[:default], condition: true, opts: opts}}

      [key]
      |> Enum.concat(opts[:allowed_flags] || [])
      |> Enum.reduce_while(
        default,
        fn
          ^key, default ->
            value = Map.get(assigns, key, false)

            if value do
              {:halt, {value, %{value: value, condition: true, opts: opts}}}
            else
              {:cont, default}
            end

          flag, default ->
            value = Map.get(assigns, flag, false)

            if value do
              {:halt, {value, %{value: flag, condition: value, opts: opts}}}
            else
              {:cont, default}
            end
        end
      )
      |> then(fn {value, case_opts} ->
        case to_value(opts[:to_attributes] || value, case_opts) do
          negative when negative in [false, []] -> assigns
          value -> assign(assigns, :__computed__, assign(computed, key, value))
        end
      end)
    else
      assigns
    end
  end

  defp compute_new_fun(assigns, key, callback \\ nil) do
    computed = Map.get(assigns, :__computed__, %{__changed__: nil})

    if should_compute?(assigns, computed, key) do
      callback.()
    end
  end

  # defp compute_new(assigns, field, opts) do

  # default =
  #   if opts[:default],
  #     do: {:ok, field, opts[:default]},
  #     else: {:error, :no_value}

  # assign_new(attributes, field, fn ->
  #   case assigns do
  #     # Search for field

  #     _ ->
  #       nil
  #   end
  # end)

  # (opts[:allow_flags] || [field])
  # |> Enum.reduce_while(default, fn key, params ->
  #   case Map.fetch(assigns, key) do
  #     {:ok, false} -> {:cont, default}
  #     {:ok, value} -> {:halt, {:ok, key, value}}
  #     :error -> {:cont, default}
  #   end
  # end)
  # |> case do
  #   {:ok, key, value} ->
  #     opts =
  #       to_value(callback, opts)
  #     end
  #     {:error, :no_value} ->
  #       nil
  # end
  # defp compute_new(assigns, field, opts) do

  # default =
  #   if opts[:default],
  #     do: {:ok, field, opts[:default]},
  #     else: {:error, :no_value}

  # assign_new(attributes, field, fn ->
  #   case assigns do
  #     # Search for field

  #     _ ->
  #       nil
  #   end
  # end)

  # (opts[:allow_flags] || [field])
  # |> Enum.reduce_while(default, fn key, params ->
  #   case Map.fetch(assigns, key) do
  #     {:ok, false} -> {:cont, default}
  #     {:ok, value} -> {:halt, {:ok, key, value}}
  #     :error -> {:cont, default}
  #   end
  # end)
  # |> case do
  #   {:ok, key, value} ->
  #     opts =
  #       to_value(callback, opts)
  #     end
  #     {:error, :no_value} ->
  #       nil
  # end

  defp should_compute?(_assigns, _computed, _key, _opts \\ []) do
    true
  end

  defp computed_to_attributes(%{__computed__: computed}) do
    computed
    |> Map.drop([:__changed__])
    |> IO.inspect(label: :without_changed)
    |> Enum.reduce(%{}, fn {computed_name, prepared_attributes}, acc ->
      prepared_attributes
      |> List.wrap()
      |> Enum.reduce(acc, fn
        {name, value}, acc when name in [:class] ->
          Map.update(acc, :class, List.wrap(value), &(&1 ++ List.wrap(value)))

        {name, value}, acc ->
          Map.put(acc, name, value)

        true, acc ->
          Map.put(acc, computed_name, true)

        name, acc ->
          Map.put(acc, name, true)
      end)
    end)
  end

  defp computed_to_attributes(_), do: %{}

  # prop link_component, :atom, options: [:submit, :button, :link]

  def button(assigns) do
    assigns =
      assigns
      |> compute_static(class: "btn")
      |> compute_new_fun(:disabled)
      |> compute_new_fun(:size, fn assigns ->
        nil
      end)
      #   to_attributes: &[class: "btn-#{&1.value}"],
      #   allowed_flags: [:lg, :sm]
      # )
      |> compute_new(:type,
        to_attributes:
          &[class: if(assigns[:outline], do: "btn-outline-#{&1.value}", else: "btn-#{&1.value}")],
        allowed_flags: [:primary, :secondary, :success, :danger, :warning, :info, :light, :dark],
        default: :success
      )
      |> compute_new(:click,
        to_attributes: fn params -> [] end
      )
      |> IO.inspect()

    ~H"""
      <button {computed_to_attributes(assigns)}>Value</button>
    """
  end

  def buttonssss(assigns) do
    assigns
    |> compute_new(:disabled)
    |> IO.inspect()
    # |> assign_attribute(:type, &[class: if(assigns[:outline], do: "btn-outline-#{&1.key}", else: "btn-#{&1.key}")], use_keys: [
    #   :primary,
    #   :secondary,
    #   :success,
    #   :danger,
    #   :warning,
    #   :info,
    #   :light,
    #   :dark
    # ], default: :primary)
    |> IO.inspect()

    #   |> assign_attribute(:loading, fn -> false end)
    #   |> assign_new(:disabled, fn -> false end)
    #   |> assign_new(:inner_block, fn -> nil end)
    #   |> assign_new(:link_component, fn -> :link end)

    {opts, attributes} =
      [
        %{
          condition:
            &(&1.value &&
                &1.key in [
                  :primary,
                  :secondary,
                  :success,
                  :danger,
                  :warning,
                  :info,
                  :light,
                  :dark
                ]),
          apply:
            &[class: if(assigns[:outline], do: "btn-outline-#{&1.key}", else: "btn-#{&1.key}")],
          default: [class: "btn-primary"]
        },
        %{
          condition: &(&1.value && &1.key in [:lg, :sm]),
          apply: &[class: "btn-#{&1.key}"]
        },
        %{condition: &(&1.key == :disabled && &1.value in [true, "disabled"]), apply: :disabled},
        %{
          condition:
            &(&1.key in [
                :navigate,
                :patch,
                :href,
                :"phx-click",
                :"phx-disable-with",
                :submit,
                :replace,
                :method,
                :csrf_token
              ]),
          apply: fn opts ->
            case opts.assigns do
              %{navigate: _} ->
                opts.assigns |> Map.take([:navigate, :replace]) |> Map.to_list()

              %{patch: _} ->
                opts.assigns |> Map.take([:patch, :replace]) |> Map.to_list()

              %{href: _} ->
                opts.assigns |> Map.take([:href, :method, :csrf_token]) |> Map.to_list()

              %{"phx-click": _} ->
                opts.assigns |> Map.take([:"phx-click"]) |> Map.to_list()

              %{submit: _} ->
                (opts.assigns
                 |> Map.take([:"phx-disable-with"])
                 |> Map.to_list()) ++ [type: :submit]

              _ ->
                throw("No click action data provided")
            end
          end,
          required: "Missing :navigate, :patch, :href, :phx_click or :submit for a link"
        }
      ]
      |> then(fn directives ->
        pass_through(assigns, directives, %{class: ["btn"]})
      end)
      |> Map.split([:type])

    case Map.get(opts, :type, false) do
      :submit ->
        ~H"""
        <%= Form.submit(render_block(assigns[:inner_block]), Map.to_list(attributes)) %>
        """

      _ ->
        ~H"""
          <.link {attributes}>
            <%= render_block(assigns[:inner_block]) %>
          </.link>
        """
    end
  end

  def table(assigns) do
    ~H"""
    <table class="table">
    <tr>
      <%= for col <- @col do %>
        <th><%= col.label %></th>
      <% end %>
    </tr>
    <%= for row <- @rows do %>
      <tr id={"table-row-#{row.id}"}>
        <%= for col <- @col do %>
          <td><%= render_slot(col, row) %></td>
        <% end %>
      </tr>
    <% end %>
    </table>
    """
  end

  def dropdown(assigns) do
    assigns = assign_new(assigns, :random, fn -> :rand.uniform(1_000_000) end)

    ~H"""
    <div id={"dropdown-#{@random}"} class="dropdown">
      <div class="form-control dropdown-toggle" phx-click={JS.toggle(to: "#dropdown-menu-#{@random}", in: "fade-in-scale", out: "fade-out-scale")} data-bs-toggle="dropdown" aria-expanded="false">
        Nothing selected <%= @label %>
      </div>
      <ul id={"dropdown-menu-#{@random}"} class="dropdown-menu" style="width: 100%; padding-top: 0; margin-top: -2px; border-top-width: 0;"  phx-click-away={JS.hide(to: "#dropdown-menu-#{@random}", transition: "fade-out-scale")}>
        <li class="dropdown-item">
          Nothing selected
          Here goes filter
        </li>
        <%= render_block(assigns[:inner_block]) %>
      </ul>
    </div>
    """
  end

  def radio(assigns) do
    ~H"""
      <%= Form.radio_button(@form, @name, @value) %>
    """
  end

  def checkbox(assigns) do
    assigns = assign_new(assigns, :rand, fn -> :rand.uniform(9_9999999) end)

    ~H"""
      <span class="dropdown-item">
        <div class="form-check">
          <%= Form.checkbox(@form, @name, checked_value: @value, hidden_input: false, class: "form-check-input", id: "form-input-#{@rand}") %>
          <label class="form-check-label" for={"form-input-#{@rand}"}>
            <%= @value %>
          </label>
        </div>
      </span>
    """
  end

  def select(assigns) do
    label_text = assigns[:label] || assigns[:name]

    options =
      if assigns[:with_empty_option],
        do: ["" | assigns[:options]],
        else: assigns[:options]

    callback = if assigns[:multiselect], do: &Form.multiple_select/4, else: &Form.select/4

    ~H"""
    <div class="mb-3">
      <%= Form.label @form, @name, label_text, [class: "form-label"] %>
      <%= callback.(@form, @name, options, [class: "form-control"]) %>
      <.dropdown label={Enum.join(options, "|")}>
        <%= for o <- options do %>
          <li><.checkbox form={@form} name={@name} value={o}><%= o %></.checkbox></li>
        <% end %>
      </.dropdown>
      <%= ErrorHelpers.error_tag @form, @name %>
    </div>
    """
  end

  defp pass_through(assigns, directives, attributes \\ %{}) do
    directives = List.wrap(directives)

    assigns
    |> Enum.reduce({directives, attributes}, fn {key, value}, {directives, acc} ->
      opts = %{value: value, key: key, assigns: assigns}

      directives
      |> Enum.find_index(fn %{condition: condition} -> to_value(condition, opts) end)
      |> case do
        nil ->
          {directives, acc}

        index ->
          directives
          |> Enum.at(index)
          |> Map.get(:apply)
          |> to_value(opts)
          |> then(fn response ->
            {List.delete_at(directives, index), merge_attributes(acc, response)}
          end)
      end
    end)
    |> case do
      {[], attributes} ->
        attributes

      {remaining, attributes} ->
        remaining
        |> Enum.reduce(attributes, fn
          %{required: message}, acc ->
            throw(message)

          %{default: callback}, acc ->
            merge_attributes(acc, to_value(callback))

          _, acc ->
            acc
        end)
    end
  end

  defp to_value(callback) when is_function(callback, 0), do: callback.()
  defp to_value(value), do: value

  defp to_value(callback, opts) when is_function(callback, 1), do: callback.(opts)
  defp to_value(callback, _opts) when is_function(callback, 0), do: callback.()
  defp to_value(value, _opts), do: value

  defp merge_attributes(attributes, response) do
    response
    |> List.wrap()
    |> Enum.reduce(attributes, fn
      {:class, class}, acc ->
        new = List.wrap(class)
        Map.update(acc, :class, new, &(List.wrap(&1) ++ new))

      {key, value}, acc ->
        Map.put(acc, key, value)

      key, acc ->
        Map.put(acc, key, true)
    end)
  end
end
