defmodule Inout.PageControllerTest do
  use Inout.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "<a href=\"/login\">Login</a>"
  end
end
