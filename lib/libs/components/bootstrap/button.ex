defmodule Components.Bootstrap.Button do
  use Phoenix.Component

  def button(assigns) do
    directives = [
      &Components.Directives.type_directive/3,
      &Components.Directives.size_directive/3,
      &Components.Directives.disabled_directive/3,
      &Components.Directives.active_directive/3,
      &Components.Directives.copy_assigns_directive/3,
      &Components.Directives.click_directive/3
    ]

    ~H"""
    <button {Components.Helpers.to_attributes(:button, assigns, directives)}>
      <%= if assigns[:inner_block], do: render_slot(assigns[:inner_block]) %>
    </button>
    """
  end

  def close(assigns) do
    directives = [
      &Components.Directives.size_directive/3,
      &Components.Directives.disabled_directive/3,
      &Components.Directives.active_directive/3,
      &Components.Directives.copy_assigns_directive/3
    ]

    ~H"""
      <button {Components.Helpers.to_attributes(:close, assigns, directives)} />
    """
  end

  def group(assigns) do
    directives = [
      &Components.Directives.button_group_directive/3,
      {&Components.Directives.copy_assigns_directive/3, only: [:class]}
    ]

    ~H"""
      <div {Components.Helpers.to_attributes(:button_group, assigns, directives)}>
        <%= if assigns[:inner_block], do: render_slot(assigns[:inner_block]) %>
      </div>
    """
  end

  def toolbar(assigns) do
    directives = [
      {&Components.Directives.copy_assigns_directive/3, only: [:class]}
    ]

    ~H"""
    <div {Components.Helpers.to_attributes(:button_toolbar, assigns, directives)}>
      <%= for group <- @group do %>
        <!-- TODO: Add me-2 class to all except last element -->
        <%= render_slot(group, class: "me-2") %>
      <% end %>

      <%= if assigns[:inner_block], do: render_slot(assigns[:inner_block]) %>
    </div>
    """
  end
end
