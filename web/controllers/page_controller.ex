defmodule Inout.PageController do
  use Inout.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
