defmodule Components.Bootstrap.Link do
  use Phoenix.Component

  def link(assigns) do
    # directives = [
    # &Components.Directives.type_directive/3,
    # &Components.Directives.disabled_directive/3,
    # &Components.Directives.copy_assigns_directive/3,
    # &Components.Directives.click_directive/3
    # ]

    ~H"""
    <a {to_attributes(:link, assigns)}>
      <%= if assigns[:inner_block], do: render_slot(assigns[:inner_block]) %>
    </a>
    """
  end

  defp to_attributes(:link, assigns) do
    IO.inspect(assigns)
    %{}
  end
end
