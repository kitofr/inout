defmodule Inout.PageController do
  import GoodTimes
  use Inout.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def string_date({{y,m,d}, {hour,min,sec}}) do
    "#{y}-#{m}-#{d}T#{hour}:#{min}:#{sec}"
  end

  def check_in(conn, %{ "device" => device,  "location" => location }) do
    json conn, %{ status: "Checked in",
                  date: now |> string_date,
                  device: device,
                  location: location }
  end
end
