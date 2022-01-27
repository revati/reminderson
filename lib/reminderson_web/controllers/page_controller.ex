defmodule RemindersonWeb.PageController do
  use RemindersonWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
