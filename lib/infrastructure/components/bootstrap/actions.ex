defmodule Components.Bootstrap.Actions do
  use Phoenix.Component
  import Components.Helpers
  alias Phoenix.LiveView.JS

  def do_click(id, options \\ []) when is_binary(id), do: do_click(%JS{}, id, options)
  def do_click(%JS{} = js, id, options), do: JS.dispatch(js, "click", [{:to, "##{id}"} | options])

  def do_toggle(id, options \\ []) when is_binary(id), do: do_toggle(%JS{}, id, options)
  def do_toggle(%JS{} = js, id, options), do: JS.toggle(js, [{:to, "##{id}"} | options])
end
