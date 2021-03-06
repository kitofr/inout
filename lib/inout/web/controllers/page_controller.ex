defmodule Inout.Web.PageController do
  import GoodTimes
  use Inout.Web, :controller

  alias Inout.Web.Session

  def index(conn, _params) do
    unless Session.logged_in? conn do
      redirect conn, to: "/login"
    end
    render conn, "index.html"
  end

  def string_date({{y,m,d}, {hour,min,sec}}) do
    "#{y}-#{m}-#{d}T#{hour}:#{min}:#{sec}"
  end

  def check_in(conn, %{ "device" => device,  "location" => location }) do
    json conn, %{ status: "Checked in",
                  date: now() |> string_date,
                  device: device,
                  location: location }
  end
end
