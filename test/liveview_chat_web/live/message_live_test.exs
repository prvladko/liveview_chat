defmodule LiveviewChatWeb.MessageLiveTest do
  use LiveviewChatWeb.ConnCase
  import Phoenix.LiveViewTest
  import Plug.HTML, only: [html_escape: 1]

  test "name can't be blank", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#form", message: %{name: "", message: "hello"})
           |> render_submit() =~ html_escape("can't be blank")
  end

  test "message", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#form", message: %{name: "Simon", message: ""})
           |> render_submit() =~ html_escape("can't be blank")
  end

  test "minimum message length", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#form", message: %{name: "Simon", message: "h"})
           |> render_submit() =~ "should be at least 2 character(s)"
  end

  test "disconnected and connected mount", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "LiveView Chat"

    {:ok, _view, _html} = live(conn)
  end
end
