defmodule GlobalTaskFintechWeb.CreditApplicationLiveTest do
  use GlobalTaskFintechWeb.ConnCase

  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    user = user_fixture(%{role: "admin"})
    %{conn: log_in_user(conn, user)}
  end

  test "renders credit application form", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/credit-applications/MX/new")

    assert html =~ "Credit Application"
    assert has_element?(view, "form")
    assert html =~ "Applying from:"
    assert html =~ "MX"
  end

  test "pre-fills country from path param", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/credit-applications/MX/new")

    assert html =~ "Applying from:"
    assert html =~ "MX"
  end

  test "shows validation errors", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/credit-applications/MX/new")

    assert view
           |> form("form", credit_application: %{monthly_income: -100})
           |> render_change() =~ "must be greater than 0"
  end

  test "submits application successfully", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/credit-applications/MX/new")

    attrs = %{
      full_name: "Juan Perez",
      document_type: "curp",
      document_number: "ABC123456789012345",
      monthly_income: "1000",
      amount_requested: "5000"
    }

    {:ok, _view, _html} =
      view
      |> form("form", credit_application: attrs)
      |> render_submit()
      |> follow_redirect(conn, ~p"/credit-applications/MX/new")
  end
end
