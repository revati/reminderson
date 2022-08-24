defmodule Components.Bootstrap.DropdownNew do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  alias Phoenix.HTML.Form
  alias RemindersonWeb.ErrorHelpers

  def dropdown(assigns) do
    assigns = assigns
    |> assign_new(:toggle, fn -> nil end)

    ~H"""
      <.toggle>
        <:toggle>
          <%= if @toggle do %>
            <%= render_slot(@toggle) %>
          <% else %>
            <button class="btn btn-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
              Dropdown button
            </button>
          <% end %>
        </:toggle>
        <:target>
          <ul class="dropdown-menu" style="display: block">
            <li><a class="dropdown-item" href="#">Action</a></li>
            <li><a class="dropdown-item" href="#">Another action</a></li>
            <li><a class="dropdown-item" href="#">Something else here</a></li>
          </ul>
        </:target>
      </.toggle>
    """
  end

  def toggle(assigns) do
    assigns =
      assigns
      |> assign_new(:rand, fn -> :rand.uniform(9999999999) end)
      |> assign_new(:id, fn %{rand: rand} -> "dropdown-#{rand}" end)

    ~H"""
    <div id={@id}>
      <span data-toggle phx-click={JS.toggle(to: "##{@id} [data-target]")}>
        <%= render_slot(@toggle) %>
      </span>
      <span data-target style="display: none">
        <%= render_slot(@target) %>
      </span>
    </div>
    """
  end
end
