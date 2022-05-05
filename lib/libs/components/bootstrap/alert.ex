defmodule Components.Bootstrap.Alert do
  use Phoenix.Component
  import Components.Helpers
  alias Phoenix.LiveView.JS

  def alert(assigns) do
    assigns =
      assigns
      |> assign_new(:closable, fn -> false end)
      |> assign_type(:primary)
      |> assign_class(:alert)
      |> assign_class(&[:alert, &1[:type]])
      |> assign_class("d-flex align-items-center")
      |> assign_class("alert-dismissible fade show")
      |> assign_extra_attributes([:type, :class, :closable])

    # <Components.button
    #   type={:link}
    #   phx-click={hide_alert(@id)}
    #   class="btn-close">
    # </Components.button>

    ~H"""
    <div class={prepare_classes @class} role="alert" {@extra}>
      <%= render_slot(@inner_block) %>
      <% if @closable do %>
      <% end %>
    </div>
    """
  end

  defp hide_alert(js \\ %JS{}, id) do
    id = "##{id}"

    js
    |> JS.hide(to: id, transition: "fade-out")
    |> JS.add_class("d-none", to: id)
  end
end
