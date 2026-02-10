defmodule GlobalTaskFintechWeb.SessionController do
  use GlobalTaskFintechWeb, :controller

  alias GlobalTaskFintech.Domain.Services.AuthService
  alias GlobalTaskFintech.Infrastructure.Auth.Guardian, as: AuthGuardian

  def new(conn, _params) do
    if conn.assigns[:current_user] do
      redirect(conn, to: "/credit-applications")
    else
      render(conn, :new)
    end
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case AuthService.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> AuthGuardian.Plug.sign_in(user)
        |> redirect(to: "/credit-applications")

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> render(:new)
    end
  end

  def delete(conn, _params) do
    conn
    |> AuthGuardian.Plug.sign_out()
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/login")
  end
end
